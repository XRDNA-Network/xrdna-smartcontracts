// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IMintableAsset} from '../IMintableAsset.sol';
import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {BaseAsset, BaseAssetArgs} from '../BaseAsset.sol';
import {CommonAssetV1Storage, ERC20V1Storage, LibAssetV1Storage} from '../../libraries/LibAssetV1Storage.sol';
import {BaseProxyStorage, LibBaseProxy} from '../../libraries/LibBaseProxy.sol';
import {IAvatar} from '../../avatar/IAvatar.sol';
import {IAssetHook} from '../IAssetHook.sol';
import {IAssetRegistry} from '../IAssetRegistry.sol';

/**
 * This struct represent the initialization data for the current version of the ERC20 asset
 * It represents the standard ERC20 fields along with information about the asset's origin 
 * chain and the company allowed to issue the asset.
 * 
 * The company must have been verified to control or "own" the asset on the origin chain. 
 * Anyone can verify that this is correct by checking the origin chain address and chain id
 * deployment details of the contract and verifying that the issuer is the same company as 
 * the company controlling this synthetic version. The ERC20AssetRegistry determines which
 * assets have been verified. If disputes are discovered, registry admins can remove the 
 * assets from the registry making the asset unusable in the interoperability protocol.
 */
struct ERC20InitData {
    //the address of the original asset on the origin chain
    address originChainAddress;

    //the Company contract address allowed to mint/revoke tokens
    address issuer;

    //the number of decimal places for the token
    uint8 decimals;

    //the chain id of the origin chain
    uint256 originChainId;

    //maximum supply, set to type(uint256).max for unlimited supply
    uint256 maxSupply;

    //the name of the token
    string name;

    //the symbol of the token
    string symbol;
}

contract NTERC20Asset is BaseAsset, IMintableAsset, IERC20, IERC20Metadata, IERC20Errors {
    
    //current version of this asset. This can be used to detect whether upgrades are
    //available by comparing this version to the asset factory's current supported version.
    uint256 public override version = 1;

    event ERC20Minted(address indexed to, uint256 amt);
    event ERC20Upgraded(address indexed oldAsset, address newAsset);

    //called once at master-copy deployment
    constructor(BaseAssetArgs memory args) BaseAsset(args) {  }

    //convenience function to use for encoding init data tuple
    function encodeInitData(ERC20InitData memory data) public pure returns (bytes memory) {
        return abi.encode(data);
    }

    /**
     * @dev Initializes the ERC20 asset instance with the provided data. This is called
     * by the factory during asset creation in the registry.
     */
    function init(bytes memory initData) public onlyFactory {
        ERC20InitData memory data = abi.decode(initData, (ERC20InitData));
        require(data.issuer != address(0), "NTERC20Asset: issuer cannot be zero address");
        require(companyRegistry.isRegisteredCompany(data.issuer), "NTERC20Asset: issuer must be registered company");
        require(data.originChainAddress != address(0), "NTERC20Asset: originChainAddress cannot be zero address"); 
        require(bytes(data.name).length > 0, "NTERC20Asset: name cannot be empty");
        require(bytes(data.symbol).length > 0, "NTERC20Asset: symbol cannot be empty");
        require(data.originChainId > 0, "NTERC20Asset: originChainId must be greater than zero");
        require(data.maxSupply > 0, "NTERC20Asset: maxSupply must be greater than zero");
        ERC20V1Storage storage s = LibAssetV1Storage.loadERC20Storage();

        s.attributes.originAddress = data.originChainAddress;
        s.attributes.issuer = data.issuer;
        s.attributes.originChainId = data.originChainId;
        s.maxSupply = data.maxSupply;
        s.attributes.name = data.name;
        s.attributes.symbol = data.symbol;
        s.attributes.decimals = data.decimals > 0 ? data.decimals : 18;
    }

    function upgrade(bytes calldata initData) public onlyIssuer {
        IAssetRegistry(assetRegistry).upgradeAsset(initData);
    }

    function upgradeComplete(address newAsset) public onlyFactory {
        //no-op
        require(newAsset != address(this), "NTERC20Asset: new upgrade contract address cannot match original");
        BaseProxyStorage storage ps = LibBaseProxy.load();
        address old = ps.implementation;
        ps.implementation = newAsset;
        emit ERC20Upgraded(old, newAsset);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _loadCommonAttributes().name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _loadCommonAttributes().symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _loadCommonAttributes().decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return LibAssetV1Storage.loadERC20Storage().totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return LibAssetV1Storage.loadERC20Storage().balances[account];
    }

   

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return LibAssetV1Storage.loadERC20Storage().allowances[owner][spender];
    }


     /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address, uint256) public virtual returns (bool) {
       revert("NTERC20Asset: transfers not allowed yet");
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address, uint256) public virtual returns (bool) {
        revert("NTERC20Asset: approvals not allowed yet");
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address, address, uint256) public virtual returns (bool) {
        revert("NTERC20Asset: transfers not allowed yet");
    }

    function canMint(address to, bytes calldata data) public override view returns (bool) {
        ERC20V1Storage storage s = LibAssetV1Storage.loadERC20Storage();
        uint256 amt = abi.decode(data, (uint256));
        require(s.totalSupply + amt <= s.maxSupply, "NTERC20Asset: max supply exceeded");
        require(to != address(0), "NTERC20Asset: cannot mint to zero address");
        return true;
    }

    function mint(address to, bytes calldata data) public nonReentrant onlyIssuer  {
        require(canMint(to, data), "NTERC20Asset: cannot mint tokens");
        uint256 amt = abi.decode(data, (uint256));
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        if(address(s.hook) != address(0)) {
            bool ok = s.hook.beforeMint(address(this), to, amt);
            if(!ok) {
                revert("NTERC20Asset: beforeMint hook rejected request");
            }
        }
        if(avatarRegistry.isAvatar(to)) {
            IAvatar avatar = IAvatar(to);
            if(!avatar.canReceiveTokensOutsideOfExperience()) {
                _verifyAvatarLocationMatchesIssuer(IAvatar(to));
            }
        }

        _mint(to, amt);
    }

    function revoke(address tgt, bytes calldata data) public nonReentrant onlyIssuer {
        IAssetHook hook = _loadCommonAttributes().hook;
        uint256 amt = abi.decode(data, (uint256));
        require(balanceOf(tgt) >= amt, "NonTransferableERC20Asset: insufficient balance to revoke");
        if(address(hook) != address(0)) {
            bool s = hook.beforeRevoke(address(this), tgt, amt);
            if(!s) {
                revert("NonTransferableERC20Asset: beforeRevoke hook rejected request");
            }
        }
        uint256 bal = balanceOf(tgt);
        _burn(tgt, amt < bal ? amt : bal);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        ERC20V1Storage storage s = LibAssetV1Storage.loadERC20Storage();
        if (from == address(0)) {
            s.totalSupply += value;
        } else {
            uint256 fromBalance = s.balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                s.balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                s.totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                s.balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal  {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        } 
        _update(address(0), account, value);
        emit ERC20Minted(account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _loadCommonAttributes() internal view override returns (CommonAssetV1Storage storage) {
        return LibAssetV1Storage.loadERC20Storage().attributes;
    }
}
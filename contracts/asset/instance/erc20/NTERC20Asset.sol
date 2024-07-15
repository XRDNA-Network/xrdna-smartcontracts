// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseAsset, BaseAssetConstructorArgs, BaseInitArgs} from '../BaseAsset.sol';
import {Version} from '../../../libraries/LibVersion.sol';
import {LibERC20, ERC20Storage} from '../../../libraries/LibERC20.sol';
import {AssetInitArgs} from '../IAsset.sol';
import {IERC20Asset} from './IERC20Asset.sol';
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


struct ERC20InitData {
    //the number of decimal places for the token
    uint8 decimals;

    //maximum supply, set to type(uint256).max for unlimited supply
    uint256 maxSupply;
}

/**
 * @title NTERC20Asset
 * @dev NTERC20Asset represents a synthetic asset for any XR chain ERC20 tokens.
 */
contract NTERC20Asset is BaseAsset, IERC20Asset {
    
    constructor(BaseAssetConstructorArgs memory args) BaseAsset(args) { }

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
    }

    /**
     * @dev Initialize the state for the ERC20 asset. NOTE: this is called on the asset's proxy and 
     * falls back to this version of the asset implementation. This is called when a new asset is 
     * created in the ERC20 registry and its proxy is cloned. This implementation is set on the proxy
     * and the init method is called in the context of the proxy (i.e. using proxy's storage).
     */
    function init(AssetInitArgs calldata args) external onlyRegistry {
        
        ERC20InitData memory initData = abi.decode(args.initData, (ERC20InitData));
        require(initData.decimals > 0, "NTERC20Asset: decimals must be greater than zero");
        require(initData.maxSupply > 0, "NTERC20Asset: max supply must be greater than zero");

        //initialize basic token info
        initBase(BaseInitArgs({
            issuer: args.issuer,
            name: args.name,
            symbol: args.symbol,
            originAddress: args.originAddress,
            originChainId: args.originChainId
        }));
        
        //then erc20 specific fields
        ERC20Storage storage erc20Store = LibERC20.load();
        erc20Store.maxSupply = initData.maxSupply;
        erc20Store.decimals = initData.decimals;
    }

    function postUpgradeInit(bytes calldata) external override onlyRegistry {
        //no-op
    }

    /**
     * @inheritdoc IERC20Asset
     */
    function decimals() external view returns (uint8) {
        return LibERC20.load().decimals;
    }

    /**
     * @inheritdoc IERC20Asset
     */
    function totalSupply() external view returns (uint256) {
        return LibERC20.load().totalSupply;
    }


    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return LibERC20.load().balances[account];
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address _owner, address spender) public view virtual returns (uint256) {
        return LibERC20.load().allowances[_owner][spender];
    }

    
    /**
     * @inheritdoc IERC20Asset
     */
    function canMint(address to, uint256 amt) public override view returns (bool) {
        require(to != address(0), "NTERC20Asset: cannot mint to zero address");
        ERC20Storage storage s = LibERC20.load();
        require(s.totalSupply + amt <= s.maxSupply, "NTERC20Asset: max supply exceeded");
        //if the asset is going to an avatar
        _verifyAvatarMinting(to);
        return true;
    }

    /**
     * @inheritdoc IERC20Asset
     */
    function mint(address to, uint256 amt) public nonReentrant onlyIssuer  {
        require(canMint(to, amt), "NTERC20Asset: cannot mint tokens");
        
        //if all good, mint tokens
        _mint(to, amt);
    }

    /**
     * @inheritdoc IERC20Asset
     */
    function revoke(address tgt, uint256 amt) public nonReentrant onlyIssuer {
        require(tgt != address(0), "NTERC20Asset: cannot revoke from zero address");
        require(amt > 0, "NTERC20Asset: revoke amount must be greater than zero");
        require(balanceOf(tgt) >= amt, "NTERC20Asset: insufficient balance to revoke");
        _burn(tgt, amt);
    }

    /**
     * @inheritdoc IERC20Asset
     */
    function transfer(address, uint256) public pure returns (bool) {
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
    function approve(address, uint256) public pure returns (bool) {
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
    function transferFrom(address, address, uint256) public pure returns (bool) {
        revert("NTERC20Asset: transfers not allowed yet");
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        ERC20Storage storage s = LibERC20.load();
        if (from == address(0)) {
            s.totalSupply += value;
        } else {
            uint256 fromBalance = s.balances[from];
            if (fromBalance < value) {
                revert IERC20Errors.ERC20InsufficientBalance(from, fromBalance, value);
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

        emit IERC20.Transfer(from, to, value);
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
            revert IERC20Errors.ERC20InvalidReceiver(address(0));
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
            revert IERC20Errors.ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }
}

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IAssetHook} from './IAssetHook.sol';

/**
 * @title Asset
 * @dev Asset represents a digital asset held on the XRDNA layer3 network or another 
 * blockchain network. Assets are registered with the AssetRegistry contract and only
 * those assets are recognized by the XRDNA layer3 protocol. Every asset has an 
 * issuer that is allowed to mint new assets.
 * 
 * Assets can also have conditions that stipulate the visibility of the asset to 
 * specific worlds or companies. While the visibility of assets is transparent for 
 * the asset owner, conditions should be used by Worlds to verify that they have 
 * permission to view or use the asset. If no conditions are attached to an asset, 
 * the asset is considered public and can be viewed or used by any world.
 */

struct ERC20InitData {
    address originChainAddress;
    address issuer;

    uint8 decimals;
    uint256 originChainId;
    uint256 totalSupply;
    string name;
    string symbol;

}

contract NonTransferableERC20Asset is ReentrancyGuard, IERC20, IERC20Metadata, IERC20Errors {


    /**
     * Fields initialized by asset constructor
     */
    address public immutable assetFactory;
    address public immutable assetRegistry;

    modifier onlyFactory() {
        require(msg.sender == assetFactory, "NonTransferableERC20: only factory allowed");
        _;
    }

    modifier onlyRegistry() {
        require(msg.sender == assetRegistry, "NonTransferableERC20: only registry allowed");
        _;
    }


    /**
     * Fields for each specific asset instance
     */
     //whether the asset has been upgraded to another asset contract version
    bool public upgraded;

    //the contract address on the origin chain
    address public originAddress;

    //the address allowed to mint new tokens
    address public issuer;

    //custom mint/transfer behavior
    IAssetHook public hook;

    //decimals
    uint8  private _decimals;

    //the chain id of the origin chain
    uint256 public originChainId;

    //total supply of the asset
    uint256 private _totalSupply;

    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;

    string private _name;
    string private _symbol;


    modifier onlyIssuer() {
        require(issuer != address(0), "NonTransferableERC20: not initialized");
        require(msg.sender == issuer, "NonTransferableERC20: only issuer allowed");
        _;
    }

    modifier notUpgraded() {
        require(!upgraded, "NonTransferableERC20: asset has been upgraded");
        _;
    }

    event ERC20Minted(address indexed to, uint256 amt);
    event ERC20Upgraded(address indexed oldAsset, address newAsset);
    event ERC20HookAdded(address indexed hook);
    event ERC20HookRemoved(address indexed hook);

    //called once at master-copy deployment
    constructor(address _assetFactory, address _assetRegistry) {
        require(_assetFactory != address(0), "NonTransferableERC20: asset factory cannot be zero address"); 
        require(_assetRegistry != address(0), "NonTransferableERC20: asset registry cannot be zero address");
        assetFactory = _assetFactory;
        assetRegistry = _assetRegistry;
    }

    function encodeInitData(ERC20InitData memory data) public pure returns (bytes memory) {
        return abi.encode(data);
    }

    function init(bytes memory initData) public onlyFactory() {
        ERC20InitData memory data = abi.decode(initData, (ERC20InitData));
        require(data.issuer != address(0), "NonTransferableERC20: issuer cannot be zero address");
        require(data.originChainAddress != address(0), "Asset: originChainAddress cannot be zero address"); 
        require(data.totalSupply > 0, "NonTransferableERC20: totalSupply must be greater than zero");  
        require(bytes(data.name).length > 0, "NonTransferableERC20: name cannot be empty");
        require(bytes(data.symbol).length > 0, "NonTransferableERC20: symbol cannot be empty");
        require(data.originChainId > 0, "NonTransferableERC20: originChainId must be greater than zero");

        originAddress = data.originChainAddress;
        issuer = data.issuer;
        originChainId = data.originChainId;
        _totalSupply = data.totalSupply;
        _name = data.name;
        _symbol = data.symbol;
        _decimals = data.decimals > 0 ? data.decimals : 18;
    }

    function upgrade(address newAsset) public onlyRegistry() {
        //no-op
        require(newAsset != address(this), "NonTransferableERC20Asset: new upgrade contract address cannot match original");
        upgraded = true;
        emit ERC20Upgraded(address(this), newAsset);
    }

    function addHook(IAssetHook _hook) public onlyIssuer {
        require(address(hook) != address(0), "NonTransferableERC721Asset: hook cannot be zero address");
        hook = _hook;
        emit ERC20HookAdded(address(_hook));
    }

    function removeHook() public onlyIssuer {
        address h = address(hook);
        emit ERC20HookRemoved(h);
        delete hook;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
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
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
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
       revert("NonTransferableERC20: transfers not allowed yet");
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
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
        revert("NonTransferableERC20: approvals not allowed yet");
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
        revert("NonTransferableERC20: transfers not allowed yet");
    }

    function mint(address to, uint256 amt) public nonReentrant onlyIssuer  {
        //FIXME: if the to address is an Avatar (check with avatar registry once 
        //launched), need to ask the avatar if it allows tokens to minted 
        //outside of its active experience.
        if(address(hook) != address(0)) {
            bool s = hook.beforeMint(address(this), to, amt);
            if(!s) {
                revert("NonTransferableERC20Asset: beforeMint hook rejected request");
            }
        }

        _mint(to, amt);
    }

    function revoke(address tgt, uint256 amt) public nonReentrant onlyIssuer {
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
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
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
    function _mint(address account, uint256 value) internal notUpgraded() {
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

}
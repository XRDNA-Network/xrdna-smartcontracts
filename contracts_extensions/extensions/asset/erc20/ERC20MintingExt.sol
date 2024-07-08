// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibAccess} from '../../../libraries/LibAccess.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../../libraries/LibRemovableEntity.sol';
import {CommonInitArgs} from '../../../interfaces/entity/IRegisteredEntity.sol';
import {IAssetMinting} from '../../../interfaces/asset/IAssetMinting.sol';
import {LibAsset} from '../../../libraries/LibAsset.sol';
import {ICompany} from '../../../company/instance/ICompany.sol';
import {ERC20Storage, LibERC20} from '../../../libraries/LibERC20.sol';
import {IAsset} from '../../../asset/IAsset.sol';
import {IAvatarRegistry} from '../../../avatar/registry/IAvatarRegistry.sol';
import {ICompanyRegistry} from '../../../company/registry/ICompanyRegistry.sol';
import {IAvatar} from '../../../avatar/instance/IAvatar.sol';
import {BaseAssetMintingExt} from '../../asset/BaseAssetMintingExt.sol';
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract ERC20MintingExt is BaseAssetMintingExt, IERC20Errors {

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ERC20_MINTING,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](3);
        sigs[0] = SelectorInfo({
            selector: this.canMint.selector,
            name: "canMint(address,bytes)"
        });
        sigs[1] = SelectorInfo({
            selector: this.mint.selector,
            name: "mint(address,bytes)"
        });
        sigs[2] = SelectorInfo({
            selector: this.revoke.selector,
            name: "revoke(address,bytes)"
        });

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no-op
    }


     /**
     * @dev determine if the asset can be minted
     * @param to the address to mint to
     * @param data the data to use for minting, which should be an encoded uint256 amount
     */
    function canMint(address to, bytes calldata data) public override view returns (bool) {
        require(to != address(0), "NTERC20Asset: cannot mint to zero address");
        ERC20Storage storage s = LibERC20.load();
        
        uint256 amt = abi.decode(data, (uint256));
        require(s.totalSupply + amt <= s.maxSupply, "NTERC20Asset: max supply exceeded");
        //if the asset is going to an avatar
        IAvatarRegistry avatarRegistry = IAsset(address(this)).avatarRegistry();
        if(avatarRegistry.isRegistered(to)) {
            IAvatar avatar = IAvatar(to);
            //If the avatar opts to restrict token minting to only experiences/company
            //they are visiting
            if(!avatar.canReceiveTokensOutsideOfExperience()) {
                //check that the issuer is the same as the avatar's current experience owner
                _verifyAvatarLocationMatchesIssuer(IAvatar(to));
            }
        }
        return true;
    }

    /**
     * @dev Mints tokens to the specified address. This can only be called by the issuer
     * @param to the address to mint tokens to
     * @param data the data to use for minting, which should be an encoded uint256 amount
     */
    function mint(address to, bytes calldata data) public nonReentrant onlyIssuer  {
        require(canMint(to, data), "NTERC20Asset: cannot mint tokens");
        uint256 amt = abi.decode(data, (uint256));
        
        //if all good, mint tokens
        _mint(to, amt);
    }

    /**
     * @dev Revokes tokens from the specified address. This can only be called by the issuer
     * @param tgt the address to revoke tokens from
     * @param data the data to use for revoking, which should be an encoded uint256 amount
     * This call is used when asset balance changes on original chain and the company needs
     * to keep the recipients balance in sync. An oracle will likely be used to ensure the
     * balances are synchronized.
     */
    function revoke(address tgt, bytes calldata data) public nonReentrant onlyIssuer {
        require(tgt != address(0), "NTERC20Asset: cannot revoke from zero address");
        uint256 amt = abi.decode(data, (uint256));
        require(amt > 0, "NTERC20Asset: revoke amount must be greater than zero");
        require(IAsset(address(this)).balanceOf(tgt) >= amt, "NTERC20Asset: insufficient balance to revoke");
        _burn(tgt, amt);
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

}
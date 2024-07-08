// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ICompany, DelegatedAvatarJumpRequest} from '../../company/instance/ICompany.sol';
import {LibCompany, CompanyStorage} from '../../company/instance/LibCompany.sol';
import {IAvatar, DelegatedJumpRequest} from '../../avatar/instance/IAvatar.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';
import {IAssetRegistry} from '../../asset/registry/IAssetRegistry.sol';
import {IMintableAsset} from '../../asset/IMintableAsset.sol';
import {IAvatarRegistry} from '../../avatar/registry/IAvatarRegistry.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';

contract CompanyMintingExt is IExtension {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "CompanyAddExperienceExt: restricted to admins");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "FactoCompanyAddExperienceExtryExt: restricted to signers");
        _;
    }

    modifier onlyIfActive {
        require(LibRemovableEntity.load().active, "Company: company is not active");
        _;
    }

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.COMPANY_MINTING,
            version: Version(1,0)
        });
    }
    
    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](6);
        sigs[0] = SelectorInfo({
            selector: this.canMintERC20.selector,
            name: "canMintERC20(address,address,bytes)"
        });
        sigs[1] = SelectorInfo({
            selector: this.canMintERC721.selector,
            name: "canMintERC721(address,address,bytes)"
        });
        sigs[2] = SelectorInfo({
            selector: this.mintERC20.selector,
            name: "mintERC20(address,address,bytes)"
        });
        sigs[3] = SelectorInfo({
            selector: this.mintERC721.selector,
            name: "mintERC721(address,address,bytes)"
        });
        sigs[4] = SelectorInfo({
            selector: this.revokeERC20.selector,
            name: "revokeERC20(address,address,bytes)"
        });
        sigs[5] = SelectorInfo({
            selector: this.revokeERC721.selector,
            name: "revokeERC721(address,address,bytes)"
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

    function canMintERC20(address asset, address to, bytes calldata extra) public view onlyIfActive returns (bool) {
        //check if asset is allowed
        address erc = ICompany(address(this)).erc20Registry();
        require(erc != address(0), "Company: erc20 registry not set");
        IAssetRegistry assetRegistry = IAssetRegistry(erc);
        return _canMint(assetRegistry, asset, to, extra);
    }

    function canMintERC721(address asset, address to, bytes calldata extra) public view onlyIfActive returns (bool) {
        //check if asset is allowed
        address erc = ICompany(address(this)).erc721Registry();
        require(erc != address(0), "Company: erc721 registry not set");
        IAssetRegistry assetRegistry = IAssetRegistry(erc);
        return _canMint(assetRegistry, asset, to, extra);
    }

    function mintERC20(address asset, address to, bytes calldata data) public onlySigner onlyIfActive {
        require(canMintERC20(asset, to, data), "Company: cannot mint asset");
        IMintableAsset(asset).mint(to, data);
    }

    function mintERC721(address asset, address to, bytes calldata data) public onlySigner onlyIfActive {
        require(canMintERC721(asset, to, data), "Company: cannot mint asset");
        IMintableAsset(asset).mint(to, data);
    }

    function revokeERC20(address asset, address holder, bytes calldata data) public onlySigner onlyIfActive {
        address ar = ICompany(address(this)).erc20Registry();
        IAssetRegistry assetRegistry = IAssetRegistry(ar);
        _revoke(assetRegistry, asset, holder, data);
    }

    function revokeERC721(address asset, address holder, bytes calldata data) public onlySigner onlyIfActive {
        address ar = ICompany(address(this)).erc721Registry();
        IAssetRegistry assetRegistry = IAssetRegistry(ar);
        _revoke(assetRegistry, asset, holder, data);
    }

    function _revoke(IAssetRegistry assetRegistry, address asset, address holder, bytes calldata data) internal {
        require(assetRegistry.isRegistered(asset), "Company: asset not registered");
        IMintableAsset mintable = IMintableAsset(asset);
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        mintable.revoke(holder, data);
    }

    function _canMint(IAssetRegistry assetRegistry, address asset, address to, bytes calldata extra) internal view returns (bool) {
        require(assetRegistry.isRegistered(asset), "Company: asset not registered");

        IMintableAsset mintable = IMintableAsset(asset);
        //can only mint if company owns the asset
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        
        //and the asset allows it
        require(mintable.canMint(to, extra), "Company: cannot mint to address");

        address ar = ICompany(address(this)).avatarRegistry();
        require(ar != address(0), "Company: avatar registry not set");
        IAvatarRegistry avatarRegistry = IAvatarRegistry(ar);
        //if not an avatar, we can mint
        if(!avatarRegistry.isRegistered(to)) {
            return true;
        }

        //otherwise have to make sure avatar allows it if they are not in our experience
        IAvatar avatar = IAvatar(to);
        if(!avatar.canReceiveTokensOutsideOfExperience()) {
            address exp = avatar.location();
            require(exp != address(0), "Company: avatar location is not an experience");
            require(IExperience(exp).company() == address(this), "Company: avatar location is not in an experience owned by this company");
        }
        return true;
    }

}
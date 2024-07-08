// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntityRemovalExt} from '../BaseEntityRemovalExt.sol';
import {IRemovableEntity} from '../../../interfaces/entity/IRemovableEntity.sol';
import {LibAccess} from '../../../libraries/LibAccess.sol';
import {LibEntityRemoval} from '../../../libraries/LibEntityRemoval.sol';
import {ExtensionMetadata, IExtension} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {IRegistrarRegistry} from '../../../registrar/registry/IRegistrarRegistry.sol';
import {ITermsOwner} from '../../../interfaces/registry/ITermsOwner.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';
import {ICompanyRegistry} from '../../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../../company/instance/ICompany.sol';
import {IExperience} from '../../../experience/instance/IExperience.sol';
import {IWorld} from '../../../world/instance/IWorld.sol';
import {IRemovableEntity} from '../../../interfaces/entity/IRemovableEntity.sol';

contract AssetRemovalExt is  IExtension {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "AssetRemovalExt: restricted to admins");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ASSET_REMOVAL,
            version: Version(1,0)
        });
    }


    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no op
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](3);
        
        sigs[0] = SelectorInfo({
            selector: this.deactivateAsset.selector,
            name: "deactivateAsset(address,address,string)"
        });
        sigs[1] = SelectorInfo({
            selector: this.reactivateAsset.selector,
            name: "reactivateAsset(address,address)"
        });
        sigs[2] = SelectorInfo({
            selector: this.removeAsset.selector,
            name: "removeAsset(address,address,string)"
        });

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }


    function deactivateAsset(address asset, string calldata reason) external onlyAdmin {
        LibEntityRemoval.deactivateEntity(IRemovableEntity(asset), reason);
    }

    function reactivateAsset(address asset) external onlyAdmin {
        LibEntityRemoval.reactivateEntity(IRemovableEntity(asset));
    }

    function removeAsset(address asset, string calldata reason) external onlyAdmin {
        LibEntityRemoval.removeEntity(IRemovableEntity(asset), reason);
    }
}
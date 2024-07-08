// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {LibPortal, PortalRegistryStorage, PortalInfo} from '../../libraries/LibPortal.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {AddPortalRequest} from '../../portal/registry/IPortalRegistry.sol';
import {IPortalRegistry} from '../../portal/registry/IPortalRegistry.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {IPortalCondition} from '../../portal/IPortalCondition.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';

contract PortalRemovalExt is IExtension {

    using LibVectorAddress for VectorAddress;

    modifier onlyExpRegistry() {
        address a = IPortalRegistry(address(this)).experienceRegistry();
        require(a == msg.sender, "PortalRegistration: Only experience registry can call this function");
        _;
    }

    modifier onlyExperience {
        address a = IPortalRegistry(address(this)).experienceRegistry();
        IExperienceRegistry reg = IExperienceRegistry(a);
        require(reg.isRegistered(msg.sender), "PortalRegistration: Only registered experiences can call this function");
        require(IRemovableEntity(msg.sender).isEntityActive(), "PortalRegistration: Only active experiences can call this function");
        _;
    }
    
    /**
    * @dev Returns metadata about the extension.
    */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.PORTAL_REMOVAL,
            version: Version(1,0)
        });
    }

    /**
    * @dev Installs the extension.
    */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](3);
        sigs[0] = SelectorInfo({
            selector: this.deactivatePortal.selector,
            name: "deactivatePortal(uint256,string)"
        });
        sigs[1] = SelectorInfo({
            selector: this.reactivatePortal.selector,
            name: "reactivatePortal(uint256)"
        });
        sigs[2] = SelectorInfo({
            selector: this.removePortal.selector,
            name: "removePortal(uint256,string)"
        });
        
        
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs
        }));
    }

    function upgrade(address myAddress) external {
        //no-op
    }

    /**
     * @dev Deactivates a portal. This must be called by the experience registry
     * when an experience is deactivated.
     * @param portalId The ID of the portal to deactivate
     * @param reason The reason for deactivating the portal
     */
    function deactivatePortal(uint256 portalId, string calldata reason) external onlyExpRegistry {
        PortalRegistryStorage storage s = LibPortal.load();
        s.portals[portalId].active = false;
        address exp = address(s.portals[portalId].destination);
        emit IPortalRegistry.PortalDeactivated(portalId, exp, reason);
    }

    /**
     * @dev Reactivates a portal. This must be called by the experience registry
     * when an experience is reactivated.
     * @param portalId The ID of the portal to reactivate
     */
    function reactivatePortal(uint256 portalId) external onlyExpRegistry {
        PortalRegistryStorage storage s = LibPortal.load();
        s.portals[portalId].active = true;
        address exp = address(s.portals[portalId].destination);
        emit IPortalRegistry.PortalReactivated(portalId, exp);
    }

    /**
     * @dev Removes a portal from the registry. This must be called by the experience registry
     * when an experience is removed.
     * @param portalId The ID of the portal to remove
     * @param reason The reason for removing the portal
     */
    function removePortal(uint256 portalId, string calldata reason) external onlyExpRegistry {
        PortalRegistryStorage storage s = LibPortal.load();
        PortalInfo memory pi = s.portals[portalId];
        address exp = address(pi.destination);
        s.portals[portalId].active = false;
        emit IPortalRegistry.PortalRemoved(portalId, exp, reason);
    }

}
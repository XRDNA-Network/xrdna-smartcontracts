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

contract PortalConditionsExt is IExtension {

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
            name: LibExtensionNames.PORTAL_CONDITIONS,
            version: Version(1,0)
        });
    }

    /**
    * @dev Installs the extension.
    */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](2);
        sigs[0] = SelectorInfo({
            selector: this.addCondition.selector,
            name: "addCondition(IPortalCondition)"
        });
        sigs[1] = SelectorInfo({
            selector: this.removeCondition.selector,
            name: "removeCondition()"
        });
        
        
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs
        }));
    }

    function upgrade(address myAddress) external {
        //no-op
    }

    function addCondition(IPortalCondition condition) external onlyExperience {
        PortalRegistryStorage storage s = LibPortal.load();
        require(address(condition) != address(0), "PortalRegistry: condition address cannot be 0");
        uint256 id = s.portalIdsByExperience[msg.sender];
        require(id != 0, "PortalRegistry: experience not found");
        s.portals[id].condition = condition;
        emit IPortalRegistry.PortalConditionAdded(id, address(condition));
    }

    function removeCondition() external onlyExperience {
        PortalRegistryStorage storage s = LibPortal.load();
        uint256 portalId = s.portalIdsByExperience[msg.sender];
        s.portals[portalId].condition = IPortalCondition(address(0));
        emit IPortalRegistry.PortalConditionRemoved(portalId);
    }

}
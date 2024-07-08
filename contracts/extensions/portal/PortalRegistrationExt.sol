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

contract PortalRegistrationExt is IExtension {

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
            name: LibExtensionNames.PORTAL_REGISTRATION,
            version: Version(1,0)
        });
    }

    /**
    * @dev Installs the extension.
    */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](7);
        sigs[0] = SelectorInfo({
            selector: this.getPortalInfoById.selector,
            name: "getPortalInfoById(uint256)"
        });
        sigs[1] = SelectorInfo({
            selector: this.getPortalInfoByAddress.selector,
            name: "getPortalInfoByAddress(address)"
        });
        sigs[2] = SelectorInfo({
            selector: this.getPortalInfoByVectorAddress.selector,
            name: "getPortalInfoByVectorAddress(VectorAddress)"
        });
        sigs[3] = SelectorInfo({
            selector: this.getIdForExperience.selector,
            name: "getIdForExperience(address)"
        });
        sigs[4] = SelectorInfo({
            selector: this.getIdForVectorAddress.selector,
            name: "getIdForVectorAddress(VectorAddress)"
        });
        sigs[5] = SelectorInfo({
            selector: this.addPortal.selector,
            name: "addPortal(AddPortalRequest)"
        });
        sigs[6] = SelectorInfo({
            selector: this.changePortalFee.selector,
            name: "changePortalFee(uint256)"
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
     * @dev Returns the portal info for the given portal ID
     * @param portalId The ID of the portal
     */
    function getPortalInfoById(uint256 portalId) external view returns (PortalInfo memory) {
        return LibPortal.load().portals[portalId];
    }

    /**
     * @dev Returns the portal info for the given experience address
     * @param experience The address of the experience contract
     */
    function getPortalInfoByAddress(address experience) external view returns (PortalInfo memory) {
        PortalRegistryStorage storage store = LibPortal.load();
        uint256 portalId = store.portalIdsByExperience[experience];
        return store.portals[portalId];
    }

    /**
     * @dev Returns the portal info for the given vector address
     * @param va The vector address for a destination experience
     */
    function getPortalInfoByVectorAddress(VectorAddress memory va) external view returns (PortalInfo memory) {
        PortalRegistryStorage storage store = LibPortal.load();
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        uint256 portalId = store.portalIdsByVectorHash[hash];
        return store.portals[portalId];
    }
    
    /**
     * @dev Returns the portal ID for the given experience address
     * @param experience The address of the experience contract
     */
    function getIdForExperience(address experience) external view returns (uint256) {
        return LibPortal.load().portalIdsByExperience[experience];
    }

    /**
     * @dev Returns the portal ID for the given vector address
     * @param va The vector address for a destination experience
     */
    function getIdForVectorAddress(VectorAddress memory va) external view returns (uint256) {
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        return LibPortal.load().portalIdsByVectorHash[hash];
    }

    /*
     * @dev Adds a new portal to the registry. This must be called by the experience registry
     * when a new experience is created.
     * @param AddPortalRequest The request to add a new portal
     */
    function addPortal(AddPortalRequest memory req) external onlyExpRegistry returns (uint256)  {
        VectorAddress memory va = req.destination.vectorAddress();
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        PortalRegistryStorage storage store = LibPortal.load();
        require(store.portalIdsByVectorHash[hash] == 0, "PortalRegistry: portal already exists for this vector address");
        ++store.nextPortalId;
        uint256 portalId = store.nextPortalId; 
        store.portalIdsByVectorHash[hash] = portalId;
        store.portalIdsByExperience[address(req.destination)] = portalId;
        store.portals[portalId] = PortalInfo({
            destination: req.destination,
            condition: IPortalCondition(address(0)),
            fee: req.fee,
            active: true
        });
        emit IPortalRegistry.PortalAdded(portalId, address(req.destination));
        return portalId;
    }


    /**
     * @dev Changes the fee for a portal. This must be called by the destination experience
     */
    function changePortalFee(uint256 newFee) external onlyExperience {
        PortalRegistryStorage storage store = LibPortal.load();
        uint256 portalId = store.portalIdsByExperience[msg.sender];
        store.portals[portalId].fee = newFee;
        emit IPortalRegistry.PortalFeeChanged(portalId, newFee);
    }
    
}
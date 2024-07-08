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
import {IExperience, JumpEntryRequest} from '../../experience/instance/IExperience.sol';
import {IAvatar} from '../../avatar/instance/IAvatar.sol';
import {IAvatarRegistry} from '../../avatar/registry/IAvatarRegistry.sol';

contract PortalJumpExt is IExtension {

    struct PortalJumpMetadata {
        IExperience sourceExperience;
        IExperience destinationExperience;
        address sourceWorld;
        address sourceCompany;
        address destWorld;
        address destCompany;
        PortalInfo sourcePortal;
        PortalInfo destPortal;
    }

    using LibVectorAddress for VectorAddress;

    modifier onlyAvatar {
        address a = IPortalRegistry(address(this)).avatarRegistry();
        IAvatarRegistry reg = IAvatarRegistry(a);
        require(reg.isRegistered(msg.sender), "PortalJump: Only registered avatars can call this function");
        require(IRemovableEntity(msg.sender).isEntityActive(), "PortalJump: Only active avatars can call this function");
        _;
    }

    
    /**
    * @dev Returns metadata about the extension.
    */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.PORTAL_JUMP,
            version: Version(1,0)
        });
    }

    /**
    * @dev Installs the extension.
    */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](1);
        sigs[0] = SelectorInfo({
            selector: this.jumpRequest.selector,
            name: "jumpRequest(uint256)"
        });
        
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs
        }));
    }

    function upgrade(address myAddress) external {
        //no-op
    }

    function jumpRequest(uint256 portalId) external payable onlyAvatar returns (bytes memory) {
        
        /**
         * This contract delegates jump request authorization to the avatar. Only the avatar
         * owner can initiate a jump. And either the destination experience owner is paying 
         * for the transaction and/or fees or the avatar owner is. But the avatar contract must 
         * work out the details of payment and authorization.
         */
        PortalJumpMetadata memory meta = _getExperienceDetails(portalId);

        if(address(meta.destPortal.condition) != address(0)) {
            require(meta.destPortal.condition.canJump(address(meta.destinationExperience), meta.sourceWorld, meta.sourceCompany, address(meta.sourceExperience), msg.sender), "PortalRegistry: portal jump conditions not met");
        }

        if(meta.destPortal.fee > 0) {
            //make sure sufficient funds were forwarded in txn
            require(msg.value >= meta.destPortal.fee, "PortalRegistry: Insufficient fee attached to jump request");
             
            //if overpaid, refund the difference
            uint256 refund = msg.value - meta.destPortal.fee;
            if(refund > 0) {
                payable(msg.sender).transfer(refund);
            }
        }
        
        /** 
         * Payment for a jump must be attached to the txn. Whether it's paid by 3rd party of
         * avatar owner doesn't matter in this context.
         */
        //see if the caller has paid the fee
        return meta.destinationExperience.entering{value: meta.destPortal.fee}(JumpEntryRequest({
            sourceWorld: meta.sourceWorld,
            sourceCompany: meta.sourceCompany,
            avatar: msg.sender
        }));
         
    }

    function _getExperienceDetails(uint256 destPortalId) internal view returns (PortalJumpMetadata memory meta) {
        //get avatar's current location
        IAvatar avatar = IAvatar(msg.sender);
        address exp = avatar.location();
        require(exp != address(0), "PortalRegistry: avatar is not in a valid location");
        
        PortalRegistryStorage storage s = LibPortal.load();

        //the avatar has to be located somewhere. Even when registering through a world, the 
        //world must choose a default experience
        require(address(exp) != address(0), "PortalRegistry: avatar is not in a valid location");
        uint256 portalId = s.portalIdsByExperience[address(exp)];
        require(portalId != 0, "PortalRegistry: no portal found for the avatar's current location");
        
        require(portalId != destPortalId, "PortalRegistry: cannot jump to the same experience");

        PortalInfo storage sourcePortal = s.portals[portalId];
        require(address(sourcePortal.destination) != address(0), "PortalRegistry: could not map current location to a valid portal");
        
        //get the destination experience
        PortalInfo storage destPortal = s.portals[destPortalId];
        require(destPortal.active, "PortalRegistry: destination portal is not active");
        require(address(destPortal.destination) != address(0), "PortalRegistry: invalid destination portal id");
        return PortalJumpMetadata({
            sourcePortal: sourcePortal,
            destPortal: destPortal,
            sourceExperience: sourcePortal.destination,
            destinationExperience: destPortal.destination,
            sourceWorld: sourcePortal.destination.world(),
            sourceCompany: sourcePortal.destination.company(),
            destWorld: destPortal.destination.world(),
            destCompany: destPortal.destination.company()
        });
    }

}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseAccess} from '../base-types/BaseAccess.sol';
import {IPortalRegistry, AddPortalRequest} from './IPortalRegistry.sol';
import {PortalRegistryStorage, PortalInfo, LibPortal} from '../libraries/LibPortal.sol';
import {IPortalCondition} from './IPortalCondition.sol';
import {IExperience, JumpEntryRequest} from '../experience/instance/IExperience.sol';
import {IExperienceRegistry} from '../experience/registry/IExperienceRegistry.sol';
import {IAvatarRegistry} from '../avatar/registry/IAvatarRegistry.sol';
import {IAvatar} from '../avatar/instance/IAvatar.sol';
import {VectorAddress, LibVectorAddress} from '../libraries/LibVectorAddress.sol';
import {LibAccess} from '../libraries/LibAccess.sol';
import {Version} from '../libraries/LibTypes.sol';


struct PortalRegistryConstructorArgs {
    address avatarRegistry;
    address experienceRegistry;
}

contract PortalRegistry is BaseAccess, IPortalRegistry {

    using LibVectorAddress for VectorAddress;

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

    IExperienceRegistry public immutable experienceRegistry;
    IAvatarRegistry public immutable avatarRegistry;

    modifier onlyActiveExperience {
        require(experienceRegistry.isRegistered(msg.sender), "PortalRegistry: Only registered experiences can call this function");
        require(IExperience(msg.sender).isEntityActive(), "PortalRegistry: Only active experiences can call this function");
        _;
    }

    modifier onlyExperience {
        require(experienceRegistry.isRegistered(msg.sender), "PortalRegistry: Only registered experiences can call this function");
        _;
    }

     modifier onlyAvatar {
        require(avatarRegistry.isRegistered(msg.sender), "PortalRegistry: Only registered avatars can call this function");
        _;
    }

    constructor(PortalRegistryConstructorArgs memory args) {
        require(args.avatarRegistry != address(0), "PortalRegistry: Avatar registry cannot be the zero address" );
        require(args.experienceRegistry != address(0), "PortalRegistry: Experience registry cannot be the zero address" );
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

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
    function addPortal(AddPortalRequest memory req) external onlyActiveExperience returns (uint256)  {
        VectorAddress memory va = IExperience(msg.sender).vectorAddress();
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        PortalRegistryStorage storage store = LibPortal.load();
        require(store.portalIdsByVectorHash[hash] == 0, "PortalRegistry: portal already exists for this vector address");
        ++store.nextPortalId;
        uint256 portalId = store.nextPortalId; 
        store.portalIdsByVectorHash[hash] = portalId;
        store.portalIdsByExperience[msg.sender] = portalId;
        store.portals[portalId] = PortalInfo({
            destination: IExperience(msg.sender),
            condition: IPortalCondition(address(0)),
            fee: req.fee,
            active: true
        });
        emit IPortalRegistry.PortalAdded(portalId, msg.sender);
        return portalId;
    }
    
    /**
     * @dev Changes the fee for a portal. This must be called by the destination experience
     */
    function changePortalFee(uint256 newFee) external onlyActiveExperience {
        PortalRegistryStorage storage store = LibPortal.load();
        uint256 portalId = store.portalIdsByExperience[msg.sender];
        store.portals[portalId].fee = newFee;
        emit IPortalRegistry.PortalFeeChanged(portalId, newFee);
    }

    function deactivatePortal(uint256 portalId, string calldata reason) external onlyExperience {
        PortalRegistryStorage storage s = LibPortal.load();
        s.portals[portalId].active = false;
        address exp = address(s.portals[portalId].destination);
        require(exp == msg.sender, "PortalRegistry: only the experience can deactivate its own portal");
        emit IPortalRegistry.PortalDeactivated(portalId, exp, reason);
    }

    /**
     * @dev Reactivates a portal. This must be called by the experience registry
     * when an experience is reactivated.
     * @param portalId The ID of the portal to reactivate
     */
    function reactivatePortal(uint256 portalId) external onlyExperience {
        PortalRegistryStorage storage s = LibPortal.load();
        s.portals[portalId].active = true;
        address exp = address(s.portals[portalId].destination);
        require(exp == msg.sender, "PortalRegistry: only the experience can reactivate its own portal");
        emit IPortalRegistry.PortalReactivated(portalId, exp);
    }

    /**
     * @dev Removes a portal from the registry. This must be called by the experience registry
     * when an experience is removed.
     * @param portalId The ID of the portal to remove
     * @param reason The reason for removing the portal
     */
    function removePortal(uint256 portalId, string calldata reason) external onlyExperience {
        PortalRegistryStorage storage s = LibPortal.load();
        PortalInfo memory pi = s.portals[portalId];
        address exp = msg.sender;
        require(address(pi.destination) == exp, "PortalRegistry: only the experience can remove its own portal");
        s.portals[portalId].active = false;
        emit IPortalRegistry.PortalRemoved(portalId, exp, reason);
    }


    function addCondition(IPortalCondition condition) external onlyActiveExperience {
        PortalRegistryStorage storage s = LibPortal.load();
        require(address(condition) != address(0), "PortalRegistry: condition address cannot be 0");
        uint256 id = s.portalIdsByExperience[msg.sender];
        require(id != 0, "PortalRegistry: experience not found");
        s.portals[id].condition = condition;
        emit IPortalRegistry.PortalConditionAdded(id, address(condition));
    }

    function removeCondition() external onlyActiveExperience {
        PortalRegistryStorage storage s = LibPortal.load();
        uint256 portalId = s.portalIdsByExperience[msg.sender];
        s.portals[portalId].condition = IPortalCondition(address(0));
        emit IPortalRegistry.PortalConditionRemoved(portalId);
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
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {PortalInfo, AddPortalRequest, IPortalRegistry} from './IPortalRegistry.sol';
import {IExperience, JumpEntryRequest} from '../experience/IExperience.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {IPortalCondition} from './IPortalCondition.sol';
import {IBasicAvatar} from '../experience/IBasicAvatar.sol';
import {IAvatarRegistry} from '../avatar/IAvatarRegistry.sol';

interface IUpgradeMigration {
    function setStartingPortalIdCounter(uint256 counter) external;
}

contract PortalRegistry is IPortalRegistry, AccessControl {
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

    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    bool public upgraded;
    address public experienceRegistry;
    IAvatarRegistry public avatarRegistry;
    
    mapping(uint256 => PortalInfo) portals;
    mapping(bytes32 => uint256)  portalIdsByVectorHash;
    mapping(address => uint256)  portalIdsByExperience;
    uint256 nextPortalId;

    modifier onlyRegistry {
        require(experienceRegistry != address(0), "PortalRegistry: experience registry not set");
        require(msg.sender == experienceRegistry, "PortalRegistry: caller is not the experience registry");
        _;
    }

    modifier notUpgraded {
        require(!upgraded, "PortalRegistry: contract has been upgraded");
        _;
    }

    constructor(address[] memory admins) {
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "PortalRegistry: admin address cannot be 0");
            require(_grantRole(ADMIN_ROLE, admins[i]), "PortalRegistry: admin role grant failed");
        }
    }

    receive() external payable {}

    function setExperienceRegistry(address registry) public onlyRole(ADMIN_ROLE) notUpgraded() {
       require(registry != address(0), "PortalRegistry: invalid registry address");
       experienceRegistry = registry;
    }

    function setAvatarRegistry(address registry) public onlyRole(ADMIN_ROLE) notUpgraded() {
        require(registry != address(0), "PortalRegistry: invalid registry address");
        avatarRegistry = IAvatarRegistry(registry);
    }

    function getPortalInfoById(uint256 portalId) external view returns (PortalInfo memory) {
        return portals[portalId];
    }

    function getPortalInfoByAddress(address experience) external view returns (PortalInfo memory) {
        uint256 portalId = portalIdsByExperience[experience];
        return portals[portalId];
    }

    function getPortalInfoByVectorAddress(VectorAddress memory va) external view returns (PortalInfo memory) {
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        uint256 portalId = portalIdsByVectorHash[hash];
        return portals[portalId];
    }

    function getIdForExperience(address experience) external view returns (uint256) {
        return portalIdsByExperience[experience];
    }

    function getIdForVectorAddress(VectorAddress memory va) external view returns (uint256) {
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        return portalIdsByVectorHash[hash];
    }
    
    
    function addPortal(AddPortalRequest memory req) external onlyRegistry notUpgraded returns (uint256) {
        
        VectorAddress memory va = req.destination.vectorAddress();
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        require(portalIdsByVectorHash[hash] == 0, "PortalRegistry: portal already exists for this vector address");
        ++nextPortalId;
        uint256 portalId = nextPortalId; 
        portalIdsByVectorHash[hash] = portalId;
        portalIdsByExperience[address(req.destination)] = portalId;
        portals[portalId] = PortalInfo({
            destination: req.destination,
            condition: IPortalCondition(address(0)),
            fee: req.fee
        });
        emit PortalAdded(portalId, address(req.destination));
        return portalId;
    }

    function jumpRequest(uint256 portalId) external payable notUpgraded returns (bytes memory) {
        
        /**
         * This contract delegates jump request authorization to the avatar. Only the avatar
         * owner can initiate a jump. And either the destination experience owner is paying 
         * for the transaction and/or fees or the avatar owner is. But the avatar contract must 
         * work out the details of payment and authorization.
         */
        require(avatarRegistry.isAvatar(msg.sender), "PortalRegistry: caller must be the avatar");

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
         if(meta.destPortal.fee > 0) {
            //see if the caller has paid the fee
            return meta.destinationExperience.entering{value: meta.destPortal.fee}(JumpEntryRequest({
                sourceWorld: meta.sourceWorld,
                sourceCompany: meta.sourceCompany,
                avatar: msg.sender
            }));
         } else {
            return meta.destinationExperience.entering(JumpEntryRequest({
                sourceWorld: meta.sourceWorld,
                sourceCompany: meta.sourceCompany,
                avatar: msg.sender
            }));
         }
    }

    //NOTE: must be called by a registered destination experience contract
    function addCondition(IPortalCondition condition) external {
        //NOTE: this can still be called even if upgraded since previously 
        //registered experience may not have migrated to new registry. 
        require(address(condition) != address(0), "PortalRegistry: condition address cannot be 0");
        uint256 id = portalIdsByExperience[msg.sender];
        require(id != 0, "PortalRegistry: caller is not a registered destination experience");
        portals[id].condition = condition;
        emit PortalConditionAdded(id, address(condition));
    }

    //NOTE: must be called by a registered destination experience contract
    function removeCondition() external {
        //NOTE: this can still be called even if upgraded since previously
        //registered experience may not have migrated to new registry.
        uint256 portalId = portalIdsByExperience[msg.sender];
        require(portalId != 0, "PortalRegistry: caller is not a registered destination experience");
        portals[portalId].condition = IPortalCondition(address(0));
        emit PortalConditionRemoved(portalId);
    }

    function changePortalFee(uint256 newFee) external {
        uint256 portalId = portalIdsByExperience[msg.sender];
        require(portalId != 0, "PortalRegistry: caller is not a registered destination experience");
        portals[portalId].fee = newFee;
        emit PortalFeeChanged(portalId, newFee);
    }

    function upgradeRegistry(address newRegistry) public onlyRole(ADMIN_ROLE) notUpgraded {
        require(newRegistry != address(0), "PortalRegistry: zero address not valid");
        IUpgradeMigration(newRegistry).setStartingPortalIdCounter(nextPortalId);
        upgraded = true;
        emit PortalRegistryUpgraded(newRegistry);
    }

    function _getExperienceDetails(uint256 destPortalId) internal view returns (PortalJumpMetadata memory meta) {
        //get avatar's current location
        IBasicAvatar avatar = IBasicAvatar(msg.sender);
        VectorAddress memory currentLocation = avatar.location();

        //the avatar has to be located somewhere. Even when registering through a world, the 
        //world must choose a default experience
        require(currentLocation.p_sub > 0, "PortalRegistry: avatar is not in a valid location");
        bytes32 hash = keccak256(abi.encode(currentLocation.asLookupKey()));
        uint256 portalId = portalIdsByVectorHash[hash];
        require(portalId != 0, "PortalRegistry: no portal found for the avatar's current location");
        
        require(portalId != destPortalId, "PortalRegistry: cannot jump to the same experience");

        PortalInfo storage sourcePortal = portals[portalId];
        require(address(sourcePortal.destination) != address(0), "PortalRegistry: could not map current location to a valid portal");
        
        //get the destination experience
        PortalInfo storage destPortal = portals[destPortalId];
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
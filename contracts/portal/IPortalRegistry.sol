// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExperience} from '../experience/IExperience.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IPortalCondition} from './IPortalCondition.sol';

struct PortalInfo {
    IExperience destination;
    IPortalCondition condition;
    uint256 fee;
}

struct AddPortalRequest {
    IExperience destination;
    uint256 fee;
}

interface IPortalRegistry {

    event JumpSuccessful(uint256 indexed portalId, address indexed avatar, address indexed destination);
    event PortalAdded(uint256 indexed portalId, address indexed experience);
    event PortalConditionAdded(uint256 indexed portalId, address indexed condition);
    event PortalConditionRemoved(uint256 indexed portalId);
    event PortalRegistryUpgraded(address newRegistry);
    event PortalFeeChanged(uint256 portalId, uint256 newFee);
    event PortalDestinationUpgraded(uint256 portalId, address oldExperience, address newExperience);

    /**
     * @dev Returns the portal info for the given portal ID
     * @param portalId The ID of the portal
     */
    function getPortalInfoById(uint256 portalId) external view returns (PortalInfo memory);

    /**
     * @dev Returns the portal info for the given experience address
     * @param experience The address of the experience contract
     */
    function getPortalInfoByAddress(address experience) external view returns (PortalInfo memory);

    /**
     * @dev Returns the portal info for the given vector address
     * @param va The vector address for a destination experience
     */
    function getPortalInfoByVectorAddress(VectorAddress memory va) external view returns (PortalInfo memory);
    
    /**
     * @dev Returns the portal ID for the given experience address
     * @param experience The address of the experience contract
     */
    function getIdForExperience(address experience) external view returns (uint256);

    /**
     * @dev Returns the portal ID for the given vector address
     * @param va The vector address for a destination experience
     */
    function getIdForVectorAddress(VectorAddress memory va) external view returns (uint256);

    /*
     * @dev Adds a new portal to the registry. This must be called by the experience registry
     * when a new experience is created.
     * @param AddPortalRequest The request to add a new portal
     */
    function addPortal(AddPortalRequest memory) external returns (uint256);

    /**
     * @dev Initiates a jump request to the destination experience. This must be called
     * by a registered avatar contract.
     * @param portalId The destination portal id to jump to
     */
    function jumpRequest(uint256 portalId) external payable returns (bytes memory);
    
    /**
     * @dev Adds a condition to an existing portal. This must be called by the destination experience
     * contract, which is likely called by the company contract, to authenticate that the 
     * request is allowed by the company owning the experience.
     */
    function addCondition(IPortalCondition condition) external;

    /**
     * @dev Removes a condition from an existing portal. This must be called by the destination experience
     * contract, which is likely called by the company contract, to authenticate that the 
     * request is allowed by the company owning the experience.
     */
    function removeCondition() external;

    /**
     * @dev Changes the fee for a portal. This must be called by the destination experience
     */
    function changePortalFee(uint256 newFee) external;

    /**
     * @dev Replace the destination experience address for a portal id. This must be 
     * called by the experience registry when the experience is upgraded.
     */
    function upgradeExperiencePortal(address oldExperience, address newExperience) external;

    /**
     * If the registry is replaced, this function should be called with thew new registry 
     * so that any applicable state (portal id counter for example) can be transferred to the new registry.
     */
    function upgradeRegistry(address newRegistry) external;
}
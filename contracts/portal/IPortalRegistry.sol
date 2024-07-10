// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExperience} from '../experience/instance/IExperience.sol';
import {VectorAddress} from '../libraries/LibVectorAddress.sol';
import {IPortalCondition} from './IPortalCondition.sol';
import {PortalInfo} from '../libraries/LibPortal.sol';
import {Version} from '../libraries/LibTypes.sol';

struct AddPortalRequest {
    uint256 fee;
}

interface IPortalRegistry {

    event JumpSuccessful(uint256 indexed portalId, address indexed avatar, address indexed destination);
    event PortalAdded(uint256 indexed portalId, address indexed experience);
    event PortalDeactivated(uint256 indexed portalId, address indexed experience, string reason);
    event PortalReactivated(uint256 indexed portalId, address indexed experience);
    event PortalRemoved(uint256 indexed portalId, address indexed experience, string reason);
    event PortalConditionAdded(uint256 indexed portalId, address indexed condition);
    event PortalConditionRemoved(uint256 indexed portalId);
    event PortalRegistryUpgraded(address indexed newRegistry);
    event PortalFeeChanged(uint256 indexed portalId, uint256 indexed newFee);
    event PortalDestinationUpgraded(uint256 indexed portalId, address indexed oldExperience, address indexed newExperience);


    function version() external pure returns (Version memory);

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
     * @dev Deactivates a portal. This must be called by the experience registry
     * when an experience is deactivated.
     * @param portalId The ID of the portal to deactivate
     * @param reason The reason for deactivating the portal
     */
    function deactivatePortal(uint256 portalId, string calldata reason) external;

    /**
     * @dev Reactivates a portal. This must be called by the experience registry
     * when an experience is reactivated.
     * @param portalId The ID of the portal to reactivate
     */
    function reactivatePortal(uint256 portalId) external;

    /**
     * @dev Removes a portal from the registry. This must be called by the experience registry
     * when an experience is removed.
     * @param portalId The ID of the portal to remove
     * @param reason The reason for removing the portal
     */
    function removePortal(uint256 portalId, string calldata reason) external;

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

}

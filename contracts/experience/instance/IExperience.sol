// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';

/**
 * @dev Entry request when an avatar jumps into an experience
 */
struct JumpEntryRequest {
    address sourceWorld;
    address sourceCompany;
    address avatar;
}

struct ExperienceInitArgs {
    string name;
    address company;
    VectorAddress vector;
    bytes initData;
}


struct ExperienceInfo {
    address company;
    address world;
    uint256 portalId;
}

/**
 * @dev Interface for an experience. An experience is something a Company offers within a 
 * World. Avatars portal into experiences to interact with them. Portaling into an Experience
 * may incur a fee paid by the Avatar. An Experience may have hooks that are called when an
 * Avatar enters the experience that can further evaluate the request outside of Portal conditions.
 */
interface IExperience is IRemovableEntity {

    event ConnectionDetailsChanged(bytes newDetails);
    event JumpEntry(address indexed sourceWorld, address indexed sourceCompany, address indexed avatar, uint256 attachedFees);
    event HookAdded(address indexed hook);
    event HookRemoved(address indexed hook);
    event ExperienceUpgraded(address indexed oldVersion, address indexed newVersion);
    event PortalFeeChanged(uint256 newFee);
    event ExperienceDeactivated();
    

    /**
     * @dev Initializes the experience with the given arguments. This is called after cloning the experience
     * proxy and assigning this contract as its logic. It can only be called once and by its registry.
     */
    function init(ExperienceInitArgs memory args) external;

    /**
     * @dev Initializes the portal for this experience. This is called after initialization and
     * registration in the experience registry. It can only be called once and by its registry.
     */
    function initPortal() external returns (uint256 id);
    
    /**
     * @dev Returns the company that controls this experience
     */
    function company() external view returns (address);

    /**
     * @dev Returns the world that this experience is in
     */
    function world() external view returns (address);

    /**
     * @dev Returns the portal id attached to this experience
     */
    function portalId() external view returns (uint256);

    /**
     * @dev Returns the spatial vector address for this experience, which is derived
     * from its parent company and world.
     */
    function vectorAddress() external view returns (VectorAddress memory);


    /**
     * @dev Returns the entry fee for this experience
     */
    function entryFee() external view returns (uint256);

    /**
     * @dev Adds a portal condition to the experience. This can only be called by the parent company contract
     */
    function addPortalCondition(address condition) external;

    /**
     * @dev Removes the portal condition from the experience. This can only be called by the parent company contract
     */
    function removePortalCondition() external;

    /**
     * @dev Changes the portal fee for this experience. This can only be called by the parent company contract
     */
    function changePortalFee(uint256 fee) external;

    /**
     * @dev Returns information on how to connect to the experience. This is dependent on
     * the client and company implementation and will likely need to be decoded by the
     * company's infrastructure or API when a client attempts to jump into the experience.
     */
    function connectionDetails() external view returns (bytes memory);

    /**
     * @dev Sets the connection details for the experience. This can only be called by the parent company contract
     */
    function setConnectionDetails(bytes memory details) external;

    /**
     * @dev Called when an avatar jumps into this experience. This can only be called by the 
     * portal registry so that any portal condition is evaluated before entering the experience.
     */
    function entering(JumpEntryRequest memory request) external payable returns (bytes memory);

    /**
     * @dev Returns the experience info for the given experience address.
     */
    function getExperienceInfo(address exp) external view returns (ExperienceInfo memory);
    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {IExperienceHook} from './IExperienceHook.sol';
import {IPortalCondition} from '../portal/IPortalCondition.sol';

/**
 * @dev Entry request when an avatar jumps into an experience
 */
struct JumpEntryRequest {
    address sourceWorld;
    address sourceCompany;
    address avatar;
}

/**
 * @dev Interface for an experience. An experience is something a Company offers within a 
 * World. Avatars portal into experiences to interact with them. Portaling into an Experience
 * may incur a fee paid by the Avatar. An Experience may have hooks that are called when an
 * Avatar enters the experience that can further evaluate the request outside of Portal conditions.
 */
interface IExperience {
    event JumpEntry(address indexed sourceWorld, address indexed sourceCompany, address indexed avatar, uint256 attachedFees);
    event HookAdded(address indexed hook);
    event HookRemoved(address indexed hook);
    event ExperienceUpgraded(address indexed oldVersion, address indexed newVersion);
    event PortalFeeChanged(uint256 newFee);
    
    /**
     * @dev Returns the version of the experience contract. Can be compared with factory
     * supported versions to determine if an upgrade is needed.
     */
    function version() external view returns (uint256);

    /**
     * @dev Returns the company that controls this experience
     */
    function company() external view returns (address);

    /**
     * @dev Returns the world that this experience is in
     */
    function world() external view returns (address);

    /**
     * @dev Returns the spatial vector address for this experience, which is derived
     * from its parent company and world.
     */
    function vectorAddress() external view returns (VectorAddress memory);

    /**
     * @dev Returns the name of the experience
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the entry fee for this experience
     */
    function entryFee() external view returns (uint256);

    /**
     * @dev Returns the hooks that are called when an avatar enters this experience. This
     * can only be called by the parent company contract
     */
    function addHook(IExperienceHook hook) external;

    /**
     * @dev Removes a hook from the experience. This can only be called by the parent company contract
     */
    function removeHook() external;

    /**
     * @dev Adds a portal condition to the experience. This can only be called by the parent company contract
     */
    function addPortalCondition(IPortalCondition condition) external;

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
     * @dev Called when an avatar jumps into this experience. This can only be called by the 
     * portal registry so that any portal condition is evaluated before entering the experience.
     */
    function entering(JumpEntryRequest memory request) external payable returns (bytes memory);
    
    /**
     * @dev Initializes the experience with the given parameters. This is called by the factory
        * when the experience is created.
     */
    function init(address company, string memory _name, VectorAddress memory vector, bytes memory initData) external;
    
    /**
     * @dev Upgrades the experience to a new version. This must be initiated by the parent
     * company contract.
     */
    function upgrade(bytes memory initData) external;

    /**
     * @dev Called by the experience factory to assign new implementation address
     */
    function upgradeComplete(address nextVersion) external;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * @title IRemovable
 * @dev The IRemovable contract is the interface for entities that can be deactivated and removed.
 */
interface IRemovable {

    event EntityDeactivated(address indexed by, string reason);
    event EntityReactivated(address indexed by);
    event EntityRemoved(address indexed by, string reason);

    /**
        * @dev Returns the address of the authority that can deactivate and remove the entity and set
        * registration terms.
     */
    function termsOwner() external view returns (address);

    /**
     * @dev Deactivates the entity. This can only be called by the entity's registry but 
     * is initiated by the terms owner.
     */
    function deactivate(string memory reason) external;

    /**
     * @dev Reactivates the entity. This can only be called by the entity's registry but 
     * is initiated by the terms owner.
     */
    function reactivate() external;

    /**
     * @dev Removes the entity from the registry. This can only be called by the entity's registry but 
     * is initiated by the terms owner.
     */
    function remove(string memory reason) external;

    /**
     * @dev Determines if the entity is still active.
     */
    function isEntityActive() external view returns (bool);

    /**
     * @dev Determines if the entity is removed.
     */
    function isRemoved() external view returns (bool);
}
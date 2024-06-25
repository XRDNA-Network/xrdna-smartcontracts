// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableSupport} from "./IRemovableSupport.sol";

/**
 * @dev Interface for extensions that supports entity deactivation and removal.
 */
interface IRemovableExtension is IRemovableSupport {

    event Deactivated(address indexed by, string reason);
    event Reactivated(address indexed by);
    event Removed(address indexed by, string reason);
    
    /**
     * @dev Entity is deactivated. Only callable by its owning registry.
     */
    function deactivate(string memory reason) external;

    /**
     @dev Entity is reactivated. Only callable by its owning registry.
     */
    function reactivate() external;

    /**
     * @dev Entity is removed. Only callable by its owning registry.
     */
    function remove(string memory reason) external;

    /**
     * @dev Check if the entity is removed.
     */
    function isRemoved() external view returns (bool);

    /**
     * @dev Check if the entity is active.
     */
    function isEntityActive() external view returns (bool);
}
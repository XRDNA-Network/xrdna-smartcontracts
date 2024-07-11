// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegisteredEntity} from "./IRegisteredEntity.sol";
import {IRemovable} from "./IRemovable.sol";

/**
 * @title IRemovableEntity
 * @dev The IRemovableEntity contract is the interface for entities that can be deactivated and removed.
 */
interface IRemovableEntity is IRemovable, IRegisteredEntity {
    
}
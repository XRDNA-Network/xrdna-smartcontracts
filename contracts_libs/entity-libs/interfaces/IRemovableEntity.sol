// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegisteredEntity} from "./IRegisteredEntity.sol";
import {IRemovable} from "./IRemovable.sol";

interface IRemovableEntity is IRemovable, IRegisteredEntity {
    
}
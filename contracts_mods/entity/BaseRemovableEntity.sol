// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntity, BaseEntityConstructorArgs} from './BaseEntity.sol';
import {IRemovableEntity} from '../modules/registration/IRemovableEntity.sol';
import {LibActivation} from '../libraries/LibActivation.sol';

abstract contract BaseRemovableEntity is BaseEntity, IRemovableEntity {

    constructor(BaseEntityConstructorArgs memory args) BaseEntity(args) {}
    function deactivate(string memory reason) external override onlyRegistry {
        LibActivation.load().active = false;
        emit EntityDeactivated(msg.sender, reason);
    }

    function reactivate() external override onlyRegistry {
        LibActivation.load().active = true;
        emit EntityReactivated(msg.sender);
    }

    function remove(string memory reason) external override onlyRegistry {
        LibActivation.load().removed = true;
        emit EntityRemoved(msg.sender, reason);
    }

    function isRemoved() external view returns (bool) {
        return LibActivation.load().removed;
    }

    function isEntityActive() external view returns (bool) {
        return LibActivation.load().active;
    }
}
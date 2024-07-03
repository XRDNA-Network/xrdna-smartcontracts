// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntity, BaseEntityConstructorArgs} from './BaseEntity.sol';
import {IRemovableEntity} from '../../entity-libs/interfaces/IRemovableEntity.sol';
import {LibRemovableEntity} from '../../entity-libs/removal/LibRemovableEntity.sol';

abstract contract BaseRemovableEntity is BaseEntity, IRemovableEntity {

    constructor(BaseEntityConstructorArgs memory args) BaseEntity(args) {}
    function deactivate(string memory reason) external override onlyRegistry {
        LibRemovableEntity.load().active = false;
        emit EntityDeactivated(msg.sender, reason);
    }

    function reactivate() external override onlyRegistry {
        LibRemovableEntity.load().active = true;
        emit EntityReactivated(msg.sender);
    }

    function remove(string memory reason) external override onlyRegistry {
        LibRemovableEntity.load().removed = true;
        emit EntityRemoved(msg.sender, reason);
    }

    function isRemoved() external view returns (bool) {
        return LibRemovableEntity.load().removed;
    }

    function isEntityActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }
}
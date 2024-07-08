// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntity} from './BaseEntity.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';

abstract contract BaseRemovableEntity is BaseEntity, IRemovableEntity {

    

    function termsOwner() external view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    function deactivate(string memory reason) external onlyRegistry {
        LibRemovableEntity.load().active = false;
        emit EntityDeactivated(msg.sender, reason);
    }

    function reactivate() external onlyRegistry {
        LibRemovableEntity.load().active = true;
        emit EntityReactivated(msg.sender);
    }

    function remove(string memory reason) external onlyRegistry {
        require(!LibRemovableEntity.load().active, 'RemovableEntity: must deactivate first');
        LibRemovableEntity.load().removed = true;
        emit EntityRemoved(msg.sender, reason);
    }

    function isEntityActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isRemoved() external view returns (bool) {
        return LibRemovableEntity.load().removed;
    }
}
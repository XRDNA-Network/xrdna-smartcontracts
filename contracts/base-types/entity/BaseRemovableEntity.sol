// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntity} from './BaseEntity.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';

/**
    * @title BaseRemovableEntity
    * @dev Base contract for all removable entity types
 */
abstract contract BaseRemovableEntity is BaseEntity, IRemovableEntity {

    
    /**
     * @dev Get the authority that sets the permission to remove the entity
     */
    function termsOwner() public view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    /**
     * @dev Deactivate the entity. This is only callable by the owning registry, which handles
     * authorization checks.
     */
    function deactivate(string calldata reason) public virtual onlyRegistry {
        LibRemovableEntity.load().active = false;
        emit EntityDeactivated(msg.sender, reason);
    }

    function reactivate() public virtual onlyRegistry {
        LibRemovableEntity.load().active = true;
        emit EntityReactivated(msg.sender);
    }

    function remove(string calldata reason) public virtual onlyRegistry {
        require(!LibRemovableEntity.load().active, 'RemovableEntity: must deactivate first');
        LibRemovableEntity.load().removed = true;
        emit EntityRemoved(msg.sender, reason);
    }

    function isEntityActive() public view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isRemoved() public view returns (bool) {
        return LibRemovableEntity.load().removed;
    }
}
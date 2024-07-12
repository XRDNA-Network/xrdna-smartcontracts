// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {BaseRemovableRegistry} from './BaseRemovableRegistry.sol';
import {LibRegistration} from '../../libraries/LibRegistration.sol';
import {IVectoredEntity} from '../entity/IVectoredEntity.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';

/**
 * @title BaseVectoredRegistry
 * @dev Base contract for all registries that support vector-based entity retrieval.
 */
abstract contract BaseVectoredRegistry is BaseRemovableRegistry, IVectoredRegistry {

    /**
     * @dev Get the entity address for the given vector.
     */
    function getEntityByVector(VectorAddress calldata vector) external view returns (address) {
        return LibRegistration.getEntityByVector(vector);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external onlyEntityOwner(address(entity)) override virtual {
        VectorAddress memory v = IVectoredEntity(address(entity)).vectorAddress();
        LibEntityRemoval.removeEntityWithVector(entity, v, reason);
    }

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) public override virtual {
        VectorAddress memory v = IVectoredEntity(address(e)).vectorAddress();
        LibEntityRemoval.enforceRemovalWithVector(e, v);
    }
}
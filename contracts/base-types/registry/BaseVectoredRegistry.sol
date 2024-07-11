// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {BaseRegistry} from './BaseRegistry.sol';
import {LibRegistration} from '../../libraries/LibRegistration.sol';

/**
 * @title BaseVectoredRegistry
 * @dev Base contract for all registries that support vector-based entity retrieval.
 */
abstract contract BaseVectoredRegistry is BaseRegistry, IVectoredRegistry {

    /**
     * @dev Get the entity address for the given vector.
     */
    function getEntityByVector(VectorAddress calldata vector) external view returns (address) {
        return LibRegistration.getEntityByVector(vector);
    }
}
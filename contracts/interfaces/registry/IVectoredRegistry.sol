// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRegistry} from './IRegistry.sol';

/**
    * @title IVectoredRegistry
    * @dev The IVectoredRegistry contract is the interface for a registry of entities that can be
    * accessed by a vector address.
 */
interface IVectoredRegistry is IRegistry {

    /**
     * @dev Find the entity address by its vector address.
     */
    function getEntityByVector(VectorAddress calldata vector) external view returns (address);
}
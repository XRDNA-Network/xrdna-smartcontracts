// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetRegistry} from './registry/IAssetRegistry.sol';

/**
 * @title IMultiAssetRegistry
 * @dev To simplify asset verification regardless of its type, this interface wraps
 * multiple asset registries into a single interface. This allows for a single call 
 * to check all registries for a valid assets.
 */
interface IMultiAssetRegistry {

    /**
     * @dev Returns true if the asset is registered in any of the registries
     */
    function isRegistered(address asset) external view returns (bool);

    /**
     * @dev Registers a new asset with the registry. Only callable by the registry admin
     */
    function registerRegistry(IAssetRegistry registry) external;
}
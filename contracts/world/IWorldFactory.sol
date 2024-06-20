// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {IBaseFactory} from '../IBaseFactory.sol';
import {WorldRegistrationRequest} from './IWorldRegistry.sol';

/** 
 * @dev Interface for world factory. The world factory is responsible for creating and 
 * upgrading world contracts.
 */
interface IWorldFactory is IBaseFactory {

    /**
     * @dev Upgrades the world contract to a new version. Must be called by the world registry.
     */
    function upgradeWorld(address world, bytes memory initData) external;
    
    /**
     * @dev Creates a new world contract. Must be called by the world registry.
     */
    function createWorld(WorldRegistrationRequest memory request) external returns (address world);
}
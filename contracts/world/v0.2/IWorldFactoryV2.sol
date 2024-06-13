// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../VectorAddress.sol';
import {IBaseFactory} from '../../IBaseFactory.sol';

/**
 * Request to create a new world
 
 */
struct WorldCreateRequest {
    //owner of the world contract
    address owner;

    //any previous world version
    address oldWorld;

    //world's spatial vector address assigned by registrar
    VectorAddress baseVector;

    //world's globally unique name
    string name;

    //any additional init data for the world.
    bytes initData;
}

/** 
 * @dev Interface for world factory. The world factory is responsible for creating and 
 * upgrading world contracts.
 */
interface IWorldFactoryV2 is IBaseFactory {

    /**
     * @dev Upgrades the world contract to a new version. Must be called by the world registry.
     */
    function upgradeWorld(address world, bytes memory initData) external;
    
    /**
     * @dev Creates a new world contract. Must be called by the world registry.
     */
    function createWorld(WorldCreateRequest memory request) external returns (address world);
}
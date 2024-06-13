// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseFactory} from '../../BaseFactory.sol';
import {IBaseProxy} from '../../IBaseProxy.sol';
import {IWorldFactoryV2, WorldCreateRequest} from './IWorldFactoryV2.sol';
import {IWorldV2} from './IWorldV2.sol';

/**
 * @dev expected interface to be implemented by the next version of the world contract
 */
interface INextVersion {
    function init(bytes calldata initData) external;
}

/**
 * @dev Factory contract for creating and upgrading world contracts
 */
contract WorldFactoryV2 is BaseFactory, IWorldFactoryV2 {
    
    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    /**
     * @inheritdoc IWorldFactoryV2
     */
    function upgradeWorld(address world, bytes calldata initData) public onlyAuthorizedRegistry {
        //to upgrade, we just need to change its underlying implementation. 
        //so first, make sure the it doesn't already have the latest implementation
        address impl = IBaseProxy(world).getImplementation();
        require(impl != implementation, "Already on the latest version");
        IWorldV2(world).upgradeComplete(implementation);
        INextVersion(world).init(initData);
    }

    /**
     * @inheritdoc IWorldFactoryV2
     */
    function createWorld(WorldCreateRequest memory request) public onlyAuthorizedRegistry returns (address world) {
        world = createProxy();
        IBaseProxy(world).initProxy(implementation);
        IWorldV2(world).init(request);
    }
}
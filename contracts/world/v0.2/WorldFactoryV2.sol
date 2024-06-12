// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseFactory} from '../../BaseFactory.sol';
import {IBaseProxy} from '../../IBaseProxy.sol';
import {IWorldFactoryV2, WorldCreateRequest} from './IWorldFactoryV2.sol';
import {IWorldV2} from './IWorldV2.sol';

interface INextVersion {
    function init(bytes calldata initData) external;
}

contract WorldFactoryV2 is BaseFactory, IWorldFactoryV2 {
    
    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function upgradeWorld(address world, bytes calldata initData) public onlyAuthorizedRegistry {
        IWorldV2(world).upgradeComplete(implementation);
        INextVersion(world).init(initData);
    }

    function createWorld(WorldCreateRequest memory request) public onlyAuthorizedRegistry returns (address world) {
        world = createProxy();
        IBaseProxy(world).initProxy(implementation);
        IWorldV2(world).init(request);
    }
}
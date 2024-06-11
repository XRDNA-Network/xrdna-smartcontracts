// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseFactory} from '../../BaseFactory.sol';
import {IBaseProxy} from '../../IBaseProxy.sol';
import {IWorldFactory0_2, WorldCreateRequest} from './IWorldFactory0_2.sol';
import {IWorld0_2} from './IWorld0_2.sol';

interface INextVersion {
    function init(bytes calldata initData) external;
}

contract WorldFactory0_2 is BaseFactory, IWorldFactory0_2 {
    
    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function upgradeWorld(address world, bytes calldata initData) public onlyAuthorizedRegistry {
        IWorld0_2(world).upgradeComplete(implementation);
        INextVersion(world).init(initData);
    }

    function createWorld(WorldCreateRequest memory request) public onlyAuthorizedRegistry returns (address world) {
        world = createProxy();
        IBaseProxy(world).initProxy(implementation);
        IWorld0_2(world).init(request);
    }
}
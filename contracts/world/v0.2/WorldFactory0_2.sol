// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseFactory} from '../../BaseFactory.sol';
import {IWorldFactory0_2, WorldCreateRequest} from './IWorldFactory0_2.sol';
import {IWorld0_2} from './IWorld0_2.sol';

contract WorldFactory0_2 is BaseFactory, IWorldFactory0_2 {
    
    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function createWorld(WorldCreateRequest memory request) external onlyAuthorizedRegistry returns (address world) {
        address proxy = create();
        IWorld0_2(proxy).init(request);
        return proxy;
    }
}
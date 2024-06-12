// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../VectorAddress.sol';

struct WorldCreateRequest {
    address owner;
    address oldWorld;
    VectorAddress baseVector;
    string name;
    bytes initData;
}

interface IWorldFactoryV2 {

    function upgradeWorld(address world, bytes memory initData) external;
    function createWorld(WorldCreateRequest memory request) external returns (address world);
}
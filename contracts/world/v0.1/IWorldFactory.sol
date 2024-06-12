// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../VectorAddress.sol';


interface IWorldFactory {
    function createWorld(address owner, bytes calldata initData) external returns (address);
    function isWorldClone(address world) external view returns (bool);
}
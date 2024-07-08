// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRegistry} from './IRegistry.sol';

interface IVectoredRegistry is IRegistry {
    function getEntityByVector(VectorAddress calldata vector) external view returns (address);
}
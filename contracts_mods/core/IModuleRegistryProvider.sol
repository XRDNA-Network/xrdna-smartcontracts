// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IModuleRegistry} from './IModuleRegistry.sol';

interface IModuleRegistryProvider {
    function getModuleRegistry() external view returns (IModuleRegistry);
}
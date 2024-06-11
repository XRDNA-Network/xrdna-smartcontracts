// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetRegistry} from './IAssetRegistry.sol';
interface IMultiAssetRegistry {

    function isRegisteredAsset(address asset) external view returns (bool);
    function registerRegistry(IAssetRegistry registry) external;
}
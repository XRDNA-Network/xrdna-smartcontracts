// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBaseFactory} from '../IBaseFactory.sol';

interface IAssetFactory is IBaseFactory {
    function upgradeAsset(address asset, bytes calldata initData) external;
    function createAsset(bytes calldata initData) external returns (address asset);
}
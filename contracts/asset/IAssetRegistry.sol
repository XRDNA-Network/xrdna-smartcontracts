// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AssetCheckArgs} from './IAssetCondition.sol';

interface IAssetRegistry {
    
    function setAssetFactory(address factory) external;
    function currentAssetVersion() external view returns (uint256);
    function assetExists(address original, uint256 chainId) external view returns (bool);
    function isRegisteredAsset(address asset) external view returns (bool);
    function registerAsset(bytes calldata initData) external returns (address asset);
    function upgradeAsset(bytes calldata initData) external;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


interface IAssetRegistry {
    function currentAssetVersion(uint256 assetType) external view returns (string memory);
    function setCurrentAssetVersion(uint256 assetType, string memory version) external;
    function assetExists(address original, uint256 chainId) external view returns (bool);
    function isRegisteredAsset(address asset) external view returns (bool);
    function registerAsset(uint256 assetType, bytes calldata initData) external returns (address asset);
    function upgradeAsset(address asset, uint256 assetType, bytes calldata initData) external returns (address);
}
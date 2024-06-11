// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IAssetFactory {
    function supportsVersion() external view returns (uint256);
    function upgradeAsset(address asset, bytes calldata initData) external;
    function createAsset(bytes calldata initData) external returns (address asset);
}
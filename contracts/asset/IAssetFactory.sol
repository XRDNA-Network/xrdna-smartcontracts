// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

enum AssetType {
    UNDEFINED,
    ERC20,
    ERC721
}

interface IAssetFactory {
    function createAsset(uint256 assetType, bytes calldata initData) external returns (address asset);
}
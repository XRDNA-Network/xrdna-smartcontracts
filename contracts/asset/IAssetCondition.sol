
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct AssetCheckArgs {
    address asset;
    address world;
    address company;
    address experience;
    address avatar;
}

interface IAssetCondition {

    function canView(AssetCheckArgs memory args) external view returns (bool);
    function canUse(AssetCheckArgs memory args) external view returns (bool);
}
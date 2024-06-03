
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IAssetCondition {

    function canView(address asset, address world, address company, address experience) external view returns (bool);
    function canUse(address asset, address world, address company, address experience) external view returns (bool);
}
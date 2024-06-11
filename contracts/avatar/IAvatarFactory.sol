// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IAvatarFactory {

    function upgradeAvatar(address avatar, bytes calldata initData) external;
    function createAvatar(address company, address defaultExperience, string memory username, bytes memory initData) external returns (address);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IAvatarFactory {
    function createAvatar(address company, address defaultExperience, bytes memory initData) external returns (address);
}
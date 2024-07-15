// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from '../../interfaces/registry/IRegistry.sol';

struct CreateAvatarArgs {
    bool sendTokensToOwner;
    address startingExperience;
    address owner;
    string name;
    bytes initData;
}

interface IAvatarRegistry is IRegistry {

    function createAvatar(CreateAvatarArgs calldata args) external returns (address);
}
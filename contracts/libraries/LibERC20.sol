// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';

//erc20-specific storage fields
struct ERC20Storage {
    uint8 decimals;
    uint256 maxSupply;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
}

library LibERC20 {
    function load() internal pure returns (ERC20Storage storage store) {
        bytes32 slot = LibStorageSlots.ERC20_ASSET_STORAGE;
        assembly {
            store.slot := slot
        }
    }
}
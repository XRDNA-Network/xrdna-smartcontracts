// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';

struct EntityStorage {
    bool active;
    bool removed;
    address owner;
    string name;
}

library LibEntity {

     function load() internal pure returns (EntityStorage storage ds) {
         bytes32 slot = LibStorageSlots.ENTITY_STORAGE;
         assembly {
             ds.slot := slot
         }
     }
    
}
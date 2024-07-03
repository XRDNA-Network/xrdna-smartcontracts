// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';

struct RemovableEntityStorage {
    bool active;
    bool removed;
}

library LibActivation {
    
    function load() internal pure returns (RemovableEntityStorage storage s) {
        bytes32 slot = LibStorageSlots.ACTIVATION_STORAGE;
        assembly {
            s.slot := slot
        }
    }
}
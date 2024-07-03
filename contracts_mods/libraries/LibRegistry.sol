// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';

struct RegistryStorage {
    address entityFactory;
    address removalLogic;
    address registrationLogic;
    address changeControlLogic;
}

library LibRegistry {

    function load() internal pure returns (RegistryStorage storage store) {
        bytes32 slot = LibStorageSlots.REGISTRY_STORAGE;
        assembly {
            store.slot := slot
        }
    }
}
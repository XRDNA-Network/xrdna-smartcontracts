// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';
import {VectorAddress} from './LibVectorAddress.sol';

//storage specific to removable entities
struct RemovableEntityStorage {

    //whether the entity is active
    bool active;

    //whether the entity has been removed
    bool removed;

    //registration terms authority for the entity
    address termsOwner;

    //vector address, if applicable
    VectorAddress vector;
}

library LibRemovableEntity {

    function load() internal pure returns (RemovableEntityStorage storage ds) {
        bytes32 slot = LibStorageSlots.ACTIVATION_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

}
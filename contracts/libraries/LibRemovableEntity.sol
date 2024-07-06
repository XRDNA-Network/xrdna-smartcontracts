// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';
import {VectorAddress} from './LibVectorAddress.sol';
import {CommonInitArgs} from '../interfaces/entity/IRegisteredEntity.sol';

struct RemovableEntityStorage {
    bool active;
    bool removed;
    address termsOwner;
    address registry;
    string name;
    VectorAddress vector;
}

library LibRemovableEntity {

    function load() internal pure returns (RemovableEntityStorage storage ds) {
        bytes32 slot = LibStorageSlots.ACTIVATION_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

    function init(CommonInitArgs calldata args) internal {
         RemovableEntityStorage storage re = LibRemovableEntity.load();
        require(re.termsOwner == address(0), "RemovableEntityExt: already initialized");
        require(re.registry != address(0), "RemovableEntityExt: registry cannot be zero address");
        require(args.termsOwner != address(0), "RemovableEntityExt: terms owner cannot be zero address");

        re.name = args.name;
        re.termsOwner = args.termsOwner;
        re.active = true;
        re.vector = args.vector;
        re.registry = args.registry;
    }

}
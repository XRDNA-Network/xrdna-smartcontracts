// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct WorldStorage {
    uint256 nextPValue;
}

library LibWorld {
    function load() internal pure returns (WorldStorage storage ws) {
        bytes32 slot = LibStorageSlots.WORLD_STORAGE;
        assembly {
            ws.slot := slot
        }
    }
}
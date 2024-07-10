// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct ExperienceStorage {
    uint256 entryFee;
    uint256 portalId;
    bytes connectionDetails;
}

library LibExperience {
    function load() internal pure returns (ExperienceStorage storage ws) {
        bytes32 slot = LibStorageSlots.EXPERIENCE_STORAGE;
        assembly {
            ws.slot := slot
        }
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct ExperienceStorage {
    //entry fee for the experience
    uint256 entryFee;

    //portal generated for the experience
    uint256 portalId;

    //connection details for the experience
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
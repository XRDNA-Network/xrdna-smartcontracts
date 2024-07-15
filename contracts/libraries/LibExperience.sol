// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';

//experience-specific storage
struct ExperienceStorage {

    //the fee for the experience portal
    uint256 entryFee;

    //how to connect to the details, if applicable
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
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct CompanyStorage {
    uint256 nextPSubValue;
}

library LibCompany {
    function load() internal pure returns (CompanyStorage storage ws) {
        bytes32 slot = LibStorageSlots.COMPANY_STORAGE;
        assembly {
            ws.slot := slot
        }
    }
}
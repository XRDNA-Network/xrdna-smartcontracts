// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from './LibTypes.sol';
import {LibStorageSlots} from './LibStorageSlots.sol';

struct TermsStorage {
    mapping(bytes32 => RegistrationTerms) terms;
}

library LibTermsOwner {

    function load() internal pure returns (TermsStorage storage store) {
        bytes32 slot = LibStorageSlots.TERMS_OWNER_STORAGE;
        assembly {
            store.slot := slot
        }
    }
}
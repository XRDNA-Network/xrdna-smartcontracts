// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../modules/registration/IRegistration.sol';
import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct RegistrarTermsStorage {
    RegistrationTerms worldTerms;
}

library LibRegistrarTerms {
    function load() internal pure returns (RegistrarTermsStorage storage s) {
        bytes32 slot = LibStorageSlots.REGISTRATION_TERMS_STORAGE;
        assembly {
            s.slot := slot
        }
    }
}
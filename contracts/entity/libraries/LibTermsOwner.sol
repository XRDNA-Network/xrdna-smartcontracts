// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibAccess} from '../../core/LibAccess.sol';
import {LibRoles} from '../../core/LibRoles.sol';
import {RegistrationTerms} from '../../registry/extensions/registration/interfaces/IRegistration.sol';

struct TermsOwnerStorage {
    RegistrationTerms terms;
}

library LibTermsOwner {
    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.registration.terms.owner.storage'))) - 1)) & bytes32(uint256(0xff));

    function load() internal pure returns (TermsOwnerStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            ds.slot := slot
        }
    }
}
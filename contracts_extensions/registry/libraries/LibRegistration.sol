// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../extensions/registration/interfaces/IRegistration.sol';

struct TermedRegistration {
    address owner;
    RegistrationTerms terms;
    uint256 lastRenewed;
    uint256 deactivationTime;
}

struct RegistrationStorage {
    mapping(address => TermedRegistration) removableRegistrations;
    mapping(address => bool) staticRegistrations;
    mapping(string => address) registrationsByName;
}

library LibRegistration {
    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.registration.v1.storage'))) - 1)) & bytes32(uint256(0xff));

    function load() internal pure returns (RegistrationStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            ds.slot := slot
        }
    }
}
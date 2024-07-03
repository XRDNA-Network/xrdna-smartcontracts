// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {LibStorageSlots} from '../../core-libs/LibStorageSlots.sol';

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
    
    //not applicable to registrars or avatars
    mapping(bytes32 => address) registrationsByVector; 
}

library LibRegistrationStorage {
    
    function load() internal pure returns (RegistrationStorage storage ds) {
        bytes32 slot = LibStorageSlots.REGISTRATION_STORAGE;
        assembly {
            ds.slot := slot
        }
    }
}
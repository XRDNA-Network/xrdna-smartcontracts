// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {ICompany} from '../company/ICompany.sol';

/**
 * Storage data for ExperienceV1
 */
struct ExperienceV1Storage {

    //whether the experience contract is active or has been deactivated by the parent company
    bool active; 

    //company that owns the experience
    ICompany company;

    //operating world
    address world;

    //experience's spatial vector address assigned by company
    VectorAddress vectorAddress;

    //experience's globally unique name
    string name;

    //any fee to enter the experience
    uint256 entryFee;

    //experience's connection details, which depends on experience implementation offchain
    bytes connectionDetails;
}

/**
 * @dev Library for loading ExperienceV1Storage
 */
library LibExperienceV1Storage {
    
        bytes32 public constant EXPERIENCE_V1_STORAGE_SLOT = keccak256("_ExperienceV1Storage");
    
        /**
         * @dev Load ExperienceV1Storage from storage
         */
        function load() internal pure returns (ExperienceV1Storage storage s) {
            bytes32 slot = EXPERIENCE_V1_STORAGE_SLOT;
            assembly {
                s.slot := slot
            }
        }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {IExperienceHook} from '../experience/IExperienceHook.sol';
import {IBasicCompany} from '../experience/IBasicCompany.sol';

struct ExperienceV1Storage {
    bool upgraded;
    IBasicCompany company;
    address world;
    IExperienceHook hook;
    VectorAddress vectorAddress;
    string name;
    uint256 entryFee;
    bytes connectionDetails;
}

library LibExperienceV1Storage {
    
        bytes32 public constant EXPERIENCE_V1_STORAGE_SLOT = keccak256("_ExperienceV1Storage");
    
        function load() internal pure returns (ExperienceV1Storage storage s) {
            bytes32 slot = EXPERIENCE_V1_STORAGE_SLOT;
            assembly {
                s.slot := slot
            }
        }
}
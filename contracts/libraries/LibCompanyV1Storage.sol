// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {VectorAddress} from '../VectorAddress.sol';
import {ICompanyHook} from '../company/ICompanyHook.sol';

struct CompanyV1Storage {
    //Fields initialized by initialize function
    address owner;
    address world;
    ICompanyHook hook;
    VectorAddress vectorAddress;
    string name;
    uint256 nextPsub;
}

library LibCompanyV1Storage {
    bytes32 constant COMPANY_STORAGE_SLOT = keccak256("_CompanyV1Storage");

    function load() internal pure returns (CompanyV1Storage storage s) {
        bytes32 position = COMPANY_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}
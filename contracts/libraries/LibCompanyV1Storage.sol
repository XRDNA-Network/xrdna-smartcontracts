// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {VectorAddress} from '../VectorAddress.sol';

/**
 * Storage data for CompanyV1
 
 */
struct CompanyV1Storage {
    
    //whether the company contract is active or has been deactivated by the parent world
    bool active;

    //company primary owner address
    address owner;

    //operating world
    address world;

    //company's spatial vector address assigned by operating world
    VectorAddress vectorAddress;

    //company's globally unique name
    string name;

    //counter for experience p_sub vector offsets
    uint256 nextPsub;
}

/**
 * @dev Library to load CompanyV1Storage
 */
library LibCompanyV1Storage {
    bytes32 constant COMPANY_STORAGE_SLOT = keccak256("_CompanyV1Storage");

    /**
     * @dev Load CompanyV1Storage from storage
     */
    function load() internal pure returns (CompanyV1Storage storage s) {
        bytes32 position = COMPANY_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * Storage data for RegistrarV1
 
 */
struct RegistrarV1Storage {
    
    //whether the registrar contract is active or has been deactivated protocol admin
    bool active;

    //company primary owner address
    address owner;

    //registrar's globally unique name
    string name;
}

/**
 * @dev Library to load RegistrarV1Storage
 */
library LibRegistrarV1Storage {
    bytes32 constant V1_STORAGE_SLOT = keccak256("_RegistrarV1Storage");

    /**
     * @dev Load RegistrarV1Storage from storage
     */
    function load() internal pure returns (RegistrarV1Storage storage s) {
        bytes32 position = V1_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}
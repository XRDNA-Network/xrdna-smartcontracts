// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct EntityStorage {
    bool active;
    bool removed;
    string name;
    uint256 version;
}

library LibEntity {
    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.entity.v1.storage'))) - 1)) & bytes32(uint256(0xff));

    function load() internal pure returns (EntityStorage storage es) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            es.slot := slot
        }
    }
}
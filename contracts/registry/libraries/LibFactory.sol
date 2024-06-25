// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct EntityFactoryStorage {
    address proxyImplementation;
    address implementation;
    address authorizedRegistry;
    uint256 version;
}

library LibFactory {
    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.entityfactory.v1.storage'))) - 1)) & bytes32(uint256(0xff));

    function load() internal pure returns (EntityFactoryStorage storage ecs) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            ecs.slot := position
        }
    }
}
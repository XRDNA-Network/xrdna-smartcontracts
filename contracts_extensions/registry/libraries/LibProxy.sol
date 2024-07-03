// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct ProxyStorage {
    bool alwaysUseLatest;
    address implementation;
    address factory;
    uint256 version;
}

library LibProxy {
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.proxy.v1.storage'))) - 1)) & bytes32(uint256(0xff));

    function load() internal pure returns (ProxyStorage storage ps) {
        bytes32 position = STORAGE_SLOT;
        assembly {
            ps.slot := position
        }
    }
}
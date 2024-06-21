// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct HookStorage {
    address hook;
}

library LibHooks {

    bytes32 public constant HOOK_STORAGE_SLOT = keccak256("_HookStorage");

    function load() internal pure returns (HookStorage storage hs) {
        bytes32 slot = HOOK_STORAGE_SLOT;
        assembly {
            hs.slot := slot
        }
    }

    function isContract(address _addr) external view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setHook(HookStorage storage hs, address _hook) external {
        hs.hook = _hook;
    }

    function removeHook(HookStorage storage hs) external {
        hs.hook = address(0);
    }

    function getHook(HookStorage storage hs) external view returns (address) {
        return hs.hook;
    }
}
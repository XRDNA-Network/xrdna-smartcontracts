// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct HookStorage {
    address hook;
}

library LibHook {

    bytes32 public constant HOOK_STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.extension.v1.hook'))) - 1)) & bytes32(uint256(0xff));

    event HookSet(address hook);
    event HookRemoved();

    function load() internal pure returns (HookStorage storage hs) {
        bytes32 slot = HOOK_STORAGE_SLOT;
        assembly {
            hs.slot := slot
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setHook(address _hook) external {
        HookStorage storage hs = load();
        require(isContract(_hook), "LibHook: hook is not a contract");
        hs.hook = _hook;
        emit HookSet(_hook);
    }

    function removeHook() external {
        HookStorage storage hs = load();
        hs.hook = address(0);
        emit HookRemoved();
    }

    function getHook() external view returns (address) {
        HookStorage storage hs = load();
        return hs.hook;
    }
}
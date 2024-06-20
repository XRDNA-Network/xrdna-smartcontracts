// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {HookStorage, LibHooks} from './libraries/LibHooks.sol';
import {ISupportsHook} from './ISupportsHook.sol';

abstract contract BaseHookSupport is ISupportsHook {
    using LibHooks for HookStorage;


    modifier onlyHookAdmin {
        require(isAdmin(msg.sender), "BaseHookSupport: caller is not the admin");
        _;
    }

    function isAdmin(address caller) internal view virtual returns (bool);

    /**
     * @dev Sets the hook for the contract. This can only be called by the admin.
     */
    function setHook(address _hook) external onlyHookAdmin {
        require(_hook != address(0), "BaseHookSupport: hook is the zero address");
        require(LibHooks.isContract(_hook), "BaseHookSupport: hook is not a contract");
        LibHooks.load().setHook(_hook);
        emit HookSet(_hook);
    }

    /**
     * @dev Removes the hook for the contract. This can only be called by the admin.
     */
    function removeHook() external onlyHookAdmin {
        LibHooks.load().removeHook();
        emit HookRemoved();
    }

    /**
     * @dev Returns the current hook for the contract.
     */
    function hook() external view override returns (address) {
        return LibHooks.load().getHook();
    }
}
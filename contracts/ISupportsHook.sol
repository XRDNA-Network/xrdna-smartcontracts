// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface ISupportsHook {

    event HookSet(address hook);
    event HookRemoved();
    function setHook(address hook) external;
    function removeHook() external;
    function hook() external view returns (address);
    
}
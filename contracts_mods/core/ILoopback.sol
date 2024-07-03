// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface ILoopback {
    function staticLoop(address tgt, bytes calldata data) external returns (bytes memory);
}
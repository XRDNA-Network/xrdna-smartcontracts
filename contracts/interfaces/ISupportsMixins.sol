// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface ISupportsMixins {

    function mixins() external view returns (bytes4[] memory);
}
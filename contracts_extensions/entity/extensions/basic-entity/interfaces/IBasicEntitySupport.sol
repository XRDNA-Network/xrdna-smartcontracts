// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IBasicEntitySupport {

    function isYourFactory(address factory) external view returns (bool);
    function init(address owner, string calldata name, bytes calldata initData) external;
    function isSigner(address a) external view returns (bool);
}
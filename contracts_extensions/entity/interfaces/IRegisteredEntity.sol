// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IRegisteredEntity {

    function name() external view returns (string memory);
    function version() external view returns (uint256);
    function init(address owner, string calldata name, bytes calldata initData) external;
    function isSigner(address account) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface ISupportsSigners {
    function isSigner(address _signer) external view returns (bool);

    function addSigners(address[] calldata _signer) external;

    function removeSigners(address[] calldata _signer) external;
}
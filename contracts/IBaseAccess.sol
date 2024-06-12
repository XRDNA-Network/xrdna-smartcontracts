// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IBaseAccess {

    event ReceivedFunds(address indexed sender, uint256 value);
    event SignerAdded (address indexed signer);
    event SignerRemoved (address indexed signer);

    function addSigners(address[] calldata signers) external;
    function removeSigners(address[] calldata signers) external;
    function isSigner(address signer) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * @title IBaseAccess
 * @dev Interface for the base access control contract.
 */
interface IBaseAccess {

    event ReceivedFunds(address indexed sender, uint256 value);
    event SignerAdded (address indexed signer);
    event SignerRemoved (address indexed signer);

    /**
     * @dev Adds a list of signers to the contract.
     */
    function addSigners(address[] calldata signers) external;

    /**
     * @dev Removes a list of signers from the contract.
     */
    function removeSigners(address[] calldata signers) external;

    /**
     * @dev Returns true if the address is a signer.
     */
    function isSigner(address signer) external view returns (bool);
}
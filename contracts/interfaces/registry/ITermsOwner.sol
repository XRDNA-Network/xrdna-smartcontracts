// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


/**
    * @title ITermsOwner
    * @dev The ITermsOwner contract is the interface for authorities that determine an 
    * entity's active state and registration terms.
 */
interface ITermsOwner {

    /**
     * @dev Determines if the terms owner is still active.
     */
    function isStillActive() external view returns (bool);

    /**
     * @dev Checks whether the given address is a signer for the terms owner.
     */
    function isTermsOwnerSigner(address a) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IRegistry {
    /**
     * @dev Returns whether the caller is something that controls a entity's terms
     */
    function isActiveTermsOwner(address caller) external view returns (bool);

    /**
     * @dev Creates an instance of the entity to be registered
     */
    function createEntityInstance(address owner, string calldata name, bytes calldata initData) external returns (address);

}
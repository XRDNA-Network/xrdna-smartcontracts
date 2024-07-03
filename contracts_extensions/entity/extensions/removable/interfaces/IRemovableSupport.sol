// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IRemovableSupport {
    
    /**
     * @dev Check if the given address is the registry holding the registered entity in which
     * this extension is installed.
     */
    function isYourRegistry(address registry) external view returns (bool);
}
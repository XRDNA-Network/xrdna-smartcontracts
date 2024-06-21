// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * @title IBaseFactory
 * @dev Interface for the base factory contract.
 */
interface IBaseFactory {

    /**
     * @dev sets the proxy implementation address to use for cloning proxy instances.
     */
    function setProxyImplementation(address _proxyImplementation) external;

    /**
     * @dev returns the current proxy implementation address.
     */
    function getProxyImplementation() external view returns (address);

    /**
     * @dev sets the implementation address to use for cloning instances along
     * with the version corresponding to the new implementation.
     */
    function setImplementation(address _implementation, uint256 version) external;

    /**
     * @dev returns the current implementation address.
     */
    function getImplementation() external view returns (address);

    /**
     * @dev returns the current version of the implementation.
     */
    function supportsVersion() external view returns (uint256);
}
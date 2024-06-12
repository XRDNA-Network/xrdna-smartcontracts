// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IBaseFactory {
    function setProxyImplementation(address _proxyImplementation) external;
    function getProxyImplementation() external view returns (address);
    function setImplementation(address _implementation, uint256 version) external;
    function getImplementation() external view returns (address);
    function supportsVersion() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IEntityFactory {

    event FactoryImplementationChanged(address indexed newImpl, uint256 version);
    event FactoryProxyImplementationChanged(address indexed newImpl);

    function createEntity(address owner, string calldata name, bytes calldata initData) external returns (address);
    
    function setImplementation(address newImplementation, uint256) external;
    function getImplementation() external view returns (address);
    function currentImplVersion() external view returns (uint256);
    function setProxyImplementation(address newImplementation) external;

    function setAuthorizedRegistry(address registry) external;
}
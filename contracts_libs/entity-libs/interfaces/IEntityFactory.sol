// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from '../../core-libs/LibTypes.sol';

interface IEntityFactory {

    event FactoryImplementationChanged(address indexed newImpl, Version version);
    event FactoryProxyImplementationChanged(address indexed newImpl);
    event FactoryAuthorizedRegistryChanged(address indexed registry);

    function createEntity(address owner, string calldata name, bytes calldata initData) external returns (address);
    function upgradeEntity(address entity, bytes calldata data) external;
    
    function setEntityImplementation(address newImplementation) external;
    function getEntityImplementation() external view returns (address);
    function currentImplVersion() external view returns (Version memory);
    function setProxyImplementation(address newImplementation) external;
    function setAuthorizedRegistry(address registry) external;
}
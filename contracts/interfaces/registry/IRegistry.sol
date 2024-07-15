// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAccessControl} from '../IAccessControl.sol';
import {Version} from '../../libraries/LibVersion.sol';

/**
 * @title IRegistry
 * @dev The IRegistry contract is the base interface for a registry of entities. It covers the setting 
 * of proxy and implementation logic that registries use to clone with each entity registered. Note 
 * that each registry implementation will have its own registration scheme since different arguments
 * are required for different entities.
 */
interface IRegistry is IAccessControl {


    event RegistryEntityImplementationSet(address indexed implementation);
    event RegistryProxyImplementationSet(address indexed implementation);
    event RegistryAddedEntity(address indexed entity, address indexed owner);
    event RegistryUpgradedEntity(address indexed entity, address indexed newImplementation);
    event RegistryDowngradedEntity(address indexed entity, address indexed newImplementation);
    
    /**
     * @dev Returns the version of the registry.
     */
    function version() external pure returns(Version memory);

    /**
     * @dev Sets the entity logic implementation to use when registering new entities.
     */
    function setEntityImplementation(address implementation) external;

    /**
     * @dev Returns the entity logic implementation.
     */
    function getEntityImplementation() external view returns (address);

    /**
     * @dev Gets the version of the entity logic implementation. Can be used 
     * detect upgradeability for the entity.
     */
    function getEntityVersion() external view returns (Version memory);

    /**
     * @dev Sets the entity proxy contract that is cloned for each new entity registered.
     */
    function setProxyImplementation(address implementation) external;

    /**
     * @dev Returns the entity proxy implementation.
     */
    function getProxyImplementation() external view returns (address);

    /**
     * @dev Checks if an entity is registered in the registry
     */
    function isRegistered(address addr) external view returns (bool);

    /**
     * @dev Gets the proxy address of any entity by its globally-uniqueu registered name. This
     * will NOT apply to asset-type entities, which are not registered by name.
     */
    function getEntityByName(string calldata name) external view returns (address);

    /**
     * @dev Entity owners can request to upgrade the underlying logic of their entity contract. This is 
     * done through the registry so that arbitrary logic cannot be attached to entity proxies to circumvent
     * protocol behaviors.
     */
    function upgradeEntity(bytes calldata initData) external;

    /**
     * @dev Entity owners can request to downgrade the underlying logic of their entity contract. This is
     * done through the registry so that arbitrary logic cannot be attached to entity proxies to circumvent
     * protocol behaviors. This is useful for emergency situations where a bug is found in the latest logic.
     */
    function downgradeEntity(bytes calldata initData) external;
}
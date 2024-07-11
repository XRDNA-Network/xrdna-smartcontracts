// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from './LibVersion.sol';
import {LibStorageSlots} from './LibStorageSlots.sol';
import {IRegisteredEntity} from '../interfaces/entity/IRegisteredEntity.sol';

// Storage related to proxy/entity cloning for registries
struct FactoryStorage {

    //the current entity logic contract that gets assigned to the proxy
    address entityImplementation;

    //the proxy contract that gets cloned for each entity created
    address proxyImplementation;

    //the current version of the entity created by the registry.
    Version entityVersion;
}

library LibFactory {

    function load() internal pure returns (FactoryStorage storage ds) {
        bytes32 slot = LibStorageSlots.FACTORY_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

    /**
     * @dev Sets the proxy implementation to clone for each entity created. This should
     * be restricted to admins.
     */
    function setProxyImplementation(address _proxyImplementation) external {
        FactoryStorage storage ds = load();
        ds.proxyImplementation = _proxyImplementation;
    }

    /**
     * @dev Gets the current proxy implementation to clone for each entity created.
     */
    function getProxyImplementation() external view returns (address) {
        FactoryStorage storage ds = load();
        return ds.proxyImplementation;
    }

    /**
     * @dev Sets the entity implementation to clone for each entity created. This should
     * be restricted to admins.
     */
    function setEntityImplementation(address _entityImplementation) external {
        FactoryStorage storage ds = load();
        ds.entityImplementation = _entityImplementation;
        Version memory v = IRegisteredEntity(_entityImplementation).version();
        ds.entityVersion = v;
    }

    /**
     * @dev Gets the current entity implementation to clone for each entity created.
     */
    function getEntityImplementation() external view returns (address) {
        FactoryStorage storage ds = load();
        return ds.entityImplementation;
    }

    /**
     * @dev Gets the current entity version.
     */
    function getEntityVersion() external view returns (Version memory) {
        FactoryStorage storage ds = load();
        return ds.entityVersion;
    }
}
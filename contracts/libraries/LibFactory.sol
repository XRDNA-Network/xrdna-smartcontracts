// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from './LibTypes.sol';
import {LibStorageSlots} from './LibStorageSlots.sol';
import {IRegisteredEntity} from '../interfaces/entity/IRegisteredEntity.sol';

struct FactoryStorage {
    address entityImplementation;
    address proxyImplementation;
    Version entityVersion;
}

library LibFactory {

    function load() internal pure returns (FactoryStorage storage ds) {
        bytes32 slot = LibStorageSlots.FACTORY_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

    function setProxyImplementation(address _proxyImplementation) external {
        FactoryStorage storage ds = load();
        ds.proxyImplementation = _proxyImplementation;
    }

    function getProxyImplementation() external view returns (address) {
        FactoryStorage storage ds = load();
        return ds.proxyImplementation;
    }

    function setEntityImplementation(address _entityImplementation) external {
        FactoryStorage storage ds = load();
        ds.entityImplementation = _entityImplementation;
        Version memory v = IRegisteredEntity(_entityImplementation).version();
        ds.entityVersion = v;
    }

    function getEntityImplementation() external view returns (address) {
        FactoryStorage storage ds = load();
        return ds.entityImplementation;
    }

    function getEntityVersion() external view returns (Version memory) {
        FactoryStorage storage ds = load();
        return ds.entityVersion;
    }
}
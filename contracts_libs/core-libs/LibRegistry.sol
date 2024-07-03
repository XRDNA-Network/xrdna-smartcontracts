// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';
import {LibClone} from './LibClone.sol';
import {RegistrationTerms} from './LibTypes.sol';
import {IProxy} from '../base-types/IProxy.sol';
import {IRegisteredEntity, CommonInitArgs} from '../entity-libs/interfaces/IRegisteredEntity.sol';
import {LibRegistration} from '../entity-libs/registration/LibRegistration.sol';
import {Version} from './LibTypes.sol';
import {LibVersion} from './LibVersion.sol';
import {IRegistry} from '../base-types/registry/IRegistry.sol';
import {VectorAddress} from './LibVectorAddress.sol';
import {RegistrationWithTermsAndVector} from '../entity-libs/interfaces/IRegistration.sol';
import {CommonInitArgs} from '../entity-libs/interfaces/IRegisteredEntity.sol';

struct RegistryStorage {
    address proxyImplementation;
    address entityImplementation;
    Version entityVersion;
}

struct RegistrationRequest {
    CommonInitArgs initData;
    RegistrationTerms terms;
}

library LibRegistry {

    using LibVersion for Version;

    function load() internal pure returns (RegistryStorage storage ds) {
        bytes32 slot = LibStorageSlots.REGISTRY_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

    function setEntityImplementation(address newImpl) external {
        RegistryStorage storage rs = load();
        rs.entityImplementation = newImpl;
        rs.entityVersion = IRegisteredEntity(newImpl).version();
        emit IRegistry.EntityImplementationSet(newImpl, rs.entityVersion);
    }

    function registerNonRemovable(RegistrationRequest memory args) external returns (address proxy) {
        RegistryStorage storage rs = load();
        proxy = LibClone.clone(rs.proxyImplementation);
        require(proxy != address(0), "LibRegistry: proxy cloning failed");

        IProxy(proxy).setImplementation(rs.entityImplementation);
        IRegisteredEntity(proxy).init(args.initData);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: proxy,
            terms: args.terms,
            vector: args.initData.vector
        });
        LibRegistration.registerEntityNoRemoval(regArgs);
        emit IRegistry.RegistryAddedEntity(proxy, args.initData.owner);
    }

    function registerRemovable(RegistrationRequest memory args) external returns (address proxy) {
        RegistryStorage storage rs = load();
        proxy = LibClone.clone(rs.proxyImplementation);
        require(proxy != address(0), "LibRegistry: proxy cloning failed");

        IProxy(proxy).setImplementation(rs.entityImplementation);
        IRegisteredEntity(proxy).init(args.initData);

        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: proxy,
            terms: args.terms,
            vector: args.initData.vector
        });

        LibRegistration.registerEntityWithRemoval(regArgs);
        emit IRegistry.RegistryAddedEntity(proxy, args.initData.owner);
    }

    function upgradeEntity(bytes calldata data) external {
        RegistryStorage storage rs = load();
        IRegisteredEntity r = IRegisteredEntity(msg.sender);
        require(rs.entityVersion.greaterThan(r.version()), "RegistrarFactory: entity version is up to date");
        IProxy(msg.sender).setImplementation(rs.entityImplementation);
        r.postUpgradeInit(data);
        emit IRegistry.RegistryUpgradedEntity(msg.sender, rs.entityImplementation);
    }

}
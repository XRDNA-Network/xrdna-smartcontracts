// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IRegistry} from '../../interfaces/registry/IRegistry.sol';
import {BaseAccess} from '../BaseAccess.sol';
import {LibRegistration} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {Version, LibVersion} from '../../libraries/LibVersion.sol';
import {IRegisteredEntity} from '../../interfaces/entity/IRegisteredEntity.sol';
import {IEntityProxy} from '../entity/IEntityProxy.sol';

/**
 * @title BaseRegistry
 * @dev Base contract for all registries.
 */
abstract contract BaseRegistry is ReentrancyGuard, BaseAccess, IRegistry {

    using LibVersion for Version;
    
    modifier onlyUpgradeable {
        require(isRegistered(msg.sender), 'Registry: entity is not registered');
        canUpOrDowngrade();
        _;
    }


    function canUpOrDowngrade() internal view virtual;

    /**
     * @dev Set the entity implementation contract for the registry. All registries clone their entity
     * proxies and assign an entity implementation to that proxy.
     */
    function setEntityImplementation(address _entityImplementation) public onlyAdmin {
        LibFactory.setEntityImplementation(_entityImplementation);
    }

    /**
     * @dev Get the entity implementation contract for the registry.
     */
    function getEntityImplementation() public view returns (address) {
        return LibFactory.getEntityImplementation();
    }

    /**
     * @dev Set the proxy implementation contract for the registry. All registries clone their entity
     * proxies. This is the base contract that is cloned.
     */
    function setProxyImplementation(address _proxyImplementation) public onlyAdmin {
        LibFactory.setProxyImplementation(_proxyImplementation);
    }

    /**
     * @dev Get the proxy implementation contract for the registry.
     */
    function getProxyImplementation() public view returns (address) {
        return LibFactory.getProxyImplementation();
    }

    /**
     * @dev Get the version for the entity logic contract. This can be used to detect if an 
     * upgrade is available.
     */
    function getEntityVersion() public view returns (Version memory) {
        return LibFactory.getEntityVersion();
    }

    /**
     * @dev Entity owners can request to upgrade the underlying logic of their entity contract. This is 
     * done through the registry so that arbitrary logic cannot be attached to entity proxies to circumvent
     * protocol behaviors.
     */
    function upgradeEntity() public virtual onlyUpgradeable nonReentrant {
        IEntityProxy proxy = IEntityProxy(msg.sender); 
        Version memory v = proxy.getVersion();

        //make sure it's a higher version
        FactoryStorage storage fs = LibFactory.load();
        require(v.lessThan(fs.entityVersion), 'Registry: entity has latest version');

        //set the implementation on the entity proxy (caller)
        IEntityProxy(msg.sender).setImplementation(fs.entityImplementation);

        emit RegistryUpgradedEntity(msg.sender, fs.entityImplementation);
    }

    /**
     * @dev Entity owners can request to downgrade the underlying logic of their entity contract. This is
     * done through the registry so that arbitrary logic cannot be attached to entity proxies to circumvent
     * protocol behaviors. This is useful for emergency situations where a bug is found in the latest logic.
     */
    function downgradeEntity() public virtual onlyUpgradeable nonReentrant {
        IEntityProxy proxy = IEntityProxy(msg.sender); 
        Version memory v = proxy.getVersion();

        //make sure it's a lower version
        FactoryStorage storage fs = LibFactory.load();
        require(v.greaterThan(fs.entityVersion), 'Registry: entity version is less than current already');

        //set the implementation on the entity proxy (caller)
        IEntityProxy(msg.sender).setImplementation(fs.entityImplementation);

        emit RegistryDowngradedEntity(msg.sender, fs.entityImplementation);
    }

    /**
     * @dev Check if an entity is registered in this registry.
     */
    function isRegistered(address addr) public view returns (bool) {
        return LibRegistration.isRegistered(addr);
    }

    /**
     * @dev Get an entity by name.
     */
    function getEntityByName(string calldata name) public view returns (address) {
        return LibRegistration.getEntityByName(name);
    }

    /**
     * @dev Register an entity in the registry.
     */
    function _registerNonRemovableEntity(address entity, string calldata name) internal {
        LibRegistration.registerNonRemovableEntity(entity, name);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntityFactory, BaseEntityFactoryConstructorArgs, FactoryStorage} from '../entity/factory/BaseEntityFactory.sol';
import {ModuleVersion} from '../IModule.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {IEntityProxy} from '../../entity/IEntityProxy.sol';
import {LibVersion} from '../../libraries/LibVersion.sol';
import "hardhat/console.sol";

contract RegistrarFactory is BaseEntityFactory {

    using LibVersion for ModuleVersion;

    string public constant override name = 'RegistrarFactory';

    constructor(BaseEntityFactoryConstructorArgs memory args) BaseEntityFactory(args) {
        console.log("RegistrarFactory constructor", address(this));
    }

    function createEntity(address owner, string calldata nm, bytes calldata initData) public onlyRegistry  returns (address proxy) {
        console.log("Cloning proxy");
        proxy = _cloneProxy();
        
    }

    function upgradeEntity(address entity, bytes calldata data) public onlyRegistry {
        IRegistrar r = IRegistrar(entity);
        FactoryStorage storage s = load();
        ModuleVersion memory v = r.version();
        require(v.lessThan(s.version), "RegistrarFactory: entity version is up to date");
        IEntityProxy(entity).setImplementation(s.implementation);
        r.postUpgradeInit(data);
    }
    

}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IEntityFactory} from "./IEntityFactory.sol";
import {IModuleRegistry} from '../../../core/IModuleRegistry.sol';
import {LibModule} from '../../../core/LibModule.sol';
import {LibAccess} from '../../../libraries/LibAccess.sol';
import {LibRoles} from '../../../libraries/LibRoles.sol';
import {ModuleVersion} from '../../IModule.sol';
import {ICoreApp} from '../../../core/ICoreApp.sol';
import {LibStorageSlots} from '../../../libraries/LibStorageSlots.sol';


struct BaseEntityFactoryConstructorArgs {
    address owner;
    address[] admins;
}

struct FactoryStorage {
    address proxyImplementation;
    address implementation;
    address registry;
    ModuleVersion version;
}
abstract contract BaseEntityFactory is IEntityFactory {

    
    function load() internal pure returns (FactoryStorage storage fs) {
        bytes32 slot = LibStorageSlots.FACTORY_STORAGE;
        assembly {
            fs.slot := slot
        }
    }
    modifier onlyAdmin() {
        require(
            LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender),
            "BaseEntityFactory: only admin allowed"
        );
        _;
    }

    modifier onlyRegistry() {
        require(
            msg.sender == load().registry,
            "BaseEntityFactory: only registry allowed"
        );
        _;
    }

    constructor(BaseEntityFactoryConstructorArgs memory args) {
        LibAccess.initAccess(args.owner, args.admins);
    }

    function version() external view override returns (ModuleVersion memory) {
        return load().version;
    }
    
    function setAuthorizedRegistry(address reg) external onlyAdmin {
        require(reg != address(0), "EntityFactory: registry cannot be zero address");
        load().registry = reg;
        emit FactoryAuthorizedRegistryChanged(reg);
    }

    function setEntityImplementation(address newImpl) external onlyAdmin {
        require(newImpl != address(0), "EntityFactory: implementation cannot be zero address");
        FactoryStorage storage fs = load();
        fs.implementation = newImpl;
        ModuleVersion memory v = ICoreApp(newImpl).version();
        fs.version = v;
        emit IEntityFactory.FactoryImplementationChanged(newImpl, v);
    }

    function setProxyImplementation(address newImpl) external onlyAdmin {
        require(newImpl != address(0), "EntityFactory: proxy implementation cannot be zero address");
        load().proxyImplementation = newImpl;
        emit IEntityFactory.FactoryProxyImplementationChanged(newImpl);
    }

    function getEntityImplementation() public view returns (address) {
        return load().implementation;
    }

    function currentImplVersion() external view returns (ModuleVersion memory) {
        return load().version;
    }

    function _cloneProxy() internal returns (address proxy) {
        return _clone(load().proxyImplementation);
    }

    function _clone(address impl) internal returns (address proxy){
        require(impl != address(0), "EntityCreator: implementation not set");
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(impl);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
    }
}
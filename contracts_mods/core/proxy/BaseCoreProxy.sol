// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ModuleVersion} from "../../modules/IModule.sol";
import {IModuleRegistry, ModuleReference} from "../../core/IModuleRegistry.sol";
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibVersion} from '../../libraries/LibVersion.sol';
import {LibModule} from '../LibModule.sol';
import {LibEntityFactory} from '../../libraries/LibEntityFactory.sol';
import {ICoreApp} from '../../core/ICoreApp.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {ICoreProxy} from './ICoreProxy.sol';
import {ILoopback} from '../ILoopback.sol';
import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';
import "hardhat/console.sol";

struct BaseProxyContstructorArgs {
    address owner;
    address[] admins;
}

struct ProxyStorage {
    address implementation;
    ModuleVersion version;
}

abstract contract BaseCoreProxy is ILoopback, ICoreProxy {
    using LibVersion for ModuleVersion;

    

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "EntityProxy: only admin allowed");
        _;
    }

    modifier onlySelf {
        require(msg.sender == address(this), "EntityProxy: only self allowed");
        _;
    }

    constructor(BaseProxyContstructorArgs memory args) {
        require(args.owner != address(0), "CoreProxy: owner cannot be zero address");
        
        LibAccess.initAccess(args.owner, args.admins);
    }

    receive() external payable {}

    function staticLoop(address tgt, bytes memory data) external onlySelf returns (bytes memory) {
        console.log("Static loopback to", tgt);
        assembly {
            let success := delegatecall(gas(), tgt, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch success
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function load() internal pure returns (ProxyStorage storage ps) {
        bytes32 slot = LibStorageSlots.CORE_PROXY_STORAGE;
        assembly {
            ps.slot := slot
        }
    }

    function setImplementation(address _newImplementation) external onlyAdmin {
        
        require(_newImplementation != address(0), "EntityProxy: implementation is the zero address");
        ProxyStorage storage ps = load();
        ps.implementation = _newImplementation;
        ModuleVersion memory v = ICoreApp(_newImplementation).version();
        ps.version = v;
        emit ProxyImplementationChanged(_newImplementation, v);
        
    }

    function implementationVersion() external view returns (ModuleVersion memory) {
        return load().version;
    }

    fallback() external payable {
        address _impl = load().implementation;
        console.log("BaseCoreProxy: Fallback to", _impl);
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
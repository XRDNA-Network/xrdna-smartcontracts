// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ModuleVersion} from "../modules/IModule.sol";
import {IModuleRegistry, ModuleReference} from "../core/IModuleRegistry.sol";
import {LibAccess} from '../libraries/LibAccess.sol';
import {LibVersion} from '../libraries/LibVersion.sol';
import {LibModule} from '../core/LibModule.sol';
import {LibEntityFactory} from '../libraries/LibEntityFactory.sol';
import {IRegisteredEntity} from '../modules/registration/IRegisteredEntity.sol';
import {LibRoles} from '../libraries/LibRoles.sol';
import {IEntityProxy} from './IEntityProxy.sol';
import {IEntityFactory} from '../modules/entity/factory/IEntityFactory.sol';
import "hardhat/console.sol";

struct BaseEntityProxyConstructorArgs {
    address owningRegistry;
}

struct ProxyStorage {
    bool alwaysUseLatest;
    address implementation;
    ModuleVersion version;
}

abstract contract BaseEntityProxy is IEntityProxy {
    using LibVersion for ModuleVersion;

    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.core.proxy.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    
    address public immutable owningRegistry;

    modifier onlyRegistry {
        console.log("BaseEntityProxy: sender", msg.sender, "owningRegistry", owningRegistry);
        require(msg.sender == owningRegistry, "EntityProxy: only owning registry allowed");
        _;
    }

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "EntityProxy: only admin allowed");
        _;
    }

    modifier onlySelf {
        require(msg.sender == address(this), "EntityProxy: only self allowed");
        _;
    }

    constructor(BaseEntityProxyConstructorArgs memory args) {
        require(args.owningRegistry != address(0), "EntityProxy: owning registry cannot be zero address"); 
        owningRegistry = args.owningRegistry;
    }

    receive() external payable {}

    function load() internal pure returns (ProxyStorage storage ps) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            ps.slot := slot
        }
    }

    function staticLoop(address tgt, bytes memory data) external onlySelf returns (bytes memory) {
        
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

    function setImplementation(address _newImplementation) external onlyRegistry {
        require(_newImplementation != address(0), "EntityProxy: implementation is the zero address");
        ProxyStorage storage ps = load();
        ps.implementation = _newImplementation;
        ModuleVersion memory v = IRegisteredEntity(_newImplementation).version();
        ps.version = v;
        emit ProxyImplementationChanged(_newImplementation, v);
    }

    function setAutomaticUpgrade(bool _alwaysUseLatest) external onlyAdmin {
        load().alwaysUseLatest = _alwaysUseLatest;
    }

    function isAutomaticUpgrade() external view returns (bool) {
        return load().alwaysUseLatest;
    }

    function implementationVersion() external view returns (ModuleVersion memory) {
        return load().version;
    }

    fallback() external {
        ProxyStorage storage ps = load();
        address _impl = ps.implementation;
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
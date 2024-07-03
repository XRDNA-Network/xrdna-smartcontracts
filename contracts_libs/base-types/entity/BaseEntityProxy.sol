// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from '../../core-libs/LibTypes.sol';
import {IProxy} from '../IProxy.sol';
import {LibVersion} from '../../core-libs/LibVersion.sol';
import {LibStorageSlots} from '../../core-libs/LibStorageSlots.sol';
import {IRegisteredEntity} from '../../entity-libs/interfaces/IRegisteredEntity.sol';
import {LibAccess} from '../../core-libs/LibAccess.sol';
import {LibRoles} from '../../core-libs/LibRoles.sol';

struct BaseEntityProxyConstructorArgs {
    address owningRegistry;
}

struct ProxyStorage {
    address implementation;
    Version version;
}

abstract contract BaseEntityProxy is IProxy {
    using LibVersion for Version;

    
    address public immutable owningRegistry;

    modifier onlyRegistry {
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
        bytes32 slot = LibStorageSlots.ENTITY_PROXY_STORAGE;
        assembly {
            ps.slot := slot
        }
    }

    function setImplementation(address _newImplementation) external onlyRegistry {
        require(_newImplementation != address(0), "EntityProxy: implementation is the zero address");
        ProxyStorage storage ps = load();
        ps.implementation = _newImplementation;
        Version memory v = IRegisteredEntity(_newImplementation).version();
        ps.version = v;
        emit ProxyImplementationChanged(_newImplementation, v);
    }

    function implementationVersion() external view returns (Version memory) {
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
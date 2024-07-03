// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from '../core-libs/LibTypes.sol';
import {LibVersion} from '../core-libs/LibVersion.sol';
import {LibAccess} from '../core-libs/LibAccess.sol';
import {LibStorageSlots} from '../core-libs/LibStorageSlots.sol';
import {LibRoles} from '../core-libs/LibRoles.sol';
import {IUpgradeable} from '../IUpgradeable.sol';
import {IProxy} from './IProxy.sol';

struct BaseProxyContstructorArgs {
    address owner;
    address[] admins;
}

struct ProxyStorage {
    address implementation;
    Version version;
}

abstract contract BaseProxy is IProxy {
    using LibVersion for Version;


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
        Version memory v = IUpgradeable(_newImplementation).version();
        ps.version = v;
        emit ProxyImplementationChanged(_newImplementation, v);
    }

    function implementationVersion() external view returns (Version memory) {
        return load().version;
    }

    fallback() external payable {
        address _impl = load().implementation;
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
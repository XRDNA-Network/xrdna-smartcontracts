// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibAccess} from '../libraries/LibAccess.sol';
import {LibStorageSlots} from '../libraries/LibStorageSlots.sol';
import {Version} from '../libraries/LibTypes.sol';

interface IProvidesVersion {
    function version() external view returns (Version memory);
}

struct ProxyStorage {
    address implementation;
    Version version;
}

struct BaseProxyConstructorArgs {
    address impl;
    address owner;
    address[] admins;
}

abstract contract BaseProxy {

    modifier onlyOwner() {
        require(LibAccess.owner() == msg.sender, "EntityProxy: restricted to owner");
        _;
    }

    receive() external payable {}

    constructor(BaseProxyConstructorArgs memory args) {
        address impl = args.impl;
        require(impl != address(0), "EntityProxy: implementation is zero address");
        ProxyStorage storage ps = load();
        ps.implementation = impl;
        ps.version = IProvidesVersion(impl).version();
        LibAccess.initAccess(args.owner, args.admins);
    }

    function load() internal pure returns (ProxyStorage storage ps) {
        bytes32 slot = LibStorageSlots.ENTITY_PROXY_STORAGE;
        assembly {
            ps.slot := slot
        }
    }

    function setImplementation(address _implementation) external onlyOwner {
        Version memory version = IProvidesVersion(_implementation).version();
        ProxyStorage storage ps = load();
        ps.implementation = _implementation;
        ps.version = version;
    }

    function getImplementation() external view returns (address) {
        ProxyStorage storage ps = load();
        return ps.implementation;
    }

    function getVersion() external view returns (Version memory) {
        ProxyStorage storage ps = load();
        return ps.version;
    }

    fallback() external payable {
        ProxyStorage storage ps = load();
        address _impl = ps.implementation;
        require(_impl != address(0), "EntityProxy: implementation not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 { revert(0, returndatasize()) }
                default { return(0, returndatasize()) }
        }
    }

}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IEntityProxy} from './IEntityProxy.sol';

interface IProvidesVersion {
    function version() external view returns (Version memory);
}

struct ProxyStorage {
    address implementation;
    Version version;
}

abstract contract EntityProxy is IEntityProxy {

    address public immutable parentRegistry;
    
    modifier onlyRegistry {
        require(msg.sender == parentRegistry, 'EntityProxy: only owning registry');
        _;
    }

    receive() external payable {}

    constructor(address registry) {
        require(registry != address(0), "EntityProxy: registry is zero address");
        parentRegistry  = registry;
    }

    function load() internal pure returns (ProxyStorage storage ps) {
        bytes32 slot = LibStorageSlots.ENTITY_PROXY_STORAGE;
        assembly {
            ps.slot := slot
        }
    }

    function setImplementation(address _implementation) external onlyRegistry {
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
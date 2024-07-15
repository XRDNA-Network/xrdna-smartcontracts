// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {IEntityProxy} from './IEntityProxy.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';

//used to check entity version
interface IProvidesVersion {
    function version() external view returns (Version memory);
}

/**
 * Storage for entity proxy
 */
struct ProxyStorage {
    address implementation;
    Version version;
}

/**
    * @title EntityProxy
    * @dev Base contract for all entity proxy types. Proxies are cloned as part of the registration
    * process. They are used to forward calls to the entity implementation contract.
 */
abstract contract EntityProxy is IEntityProxy {

    // The registry that owns this entity
    address public immutable parentRegistry;
    
    modifier onlyRegistry {
        require(msg.sender == parentRegistry, 'EntityProxy: only owning registry');
        _;
    }

    modifier onlyOwner {
        require(msg.sender == LibAccess.owner(), 'EntityProxy: restricted to owner');
        _;
    }


    constructor(address registry) {
        require(registry != address(0), "EntityProxy: registry is zero address");
        parentRegistry  = registry;
    }


    receive() external payable {}

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "EntityProxy: insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    function load() internal pure returns (ProxyStorage storage ps) {
        bytes32 slot = LibStorageSlots.ENTITY_PROXY_STORAGE;
        assembly {
            ps.slot := slot
        }
    }

    /**
     * @dev Set the implementation contract for the proxy. This is only callable by the registry
     * that clones the proxy. This is called just after cloning or during an entity upgrade.
     */
    function setImplementation(address _implementation) external onlyRegistry {
        Version memory version = IProvidesVersion(_implementation).version();
        ProxyStorage storage ps = load();
        ps.implementation = _implementation;
        ps.version = version;
    }

    /**
     * @dev Get the implementation contract for the proxy
     */
    function getImplementation() external view returns (address) {
        ProxyStorage storage ps = load();
        return ps.implementation;
    }

    /**
     * @dev Get the version of the implementation contract for the proxy
     */
    function getVersion() external view returns (Version memory) {
        ProxyStorage storage ps = load();
        return ps.version;
    }

    /**
     * @dev Fallback function that forwards all calls to the implementation contract
     */
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
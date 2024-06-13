// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBaseProxy} from './IBaseProxy.sol';
import {BaseProxyStorage, LibProxyAccess, LibBaseProxy} from './libraries/LibBaseProxy.sol';
import {BaseAccess} from './BaseAccess.sol';

//base proxy constructor args
struct BaseProxyConstructorArgs {
    address factory;
    address registry;
}

/**
 * @title BaseProxy
 * @dev Base proxy contract that provides common functionality for proxies.
 */
abstract contract BaseProxy is IBaseProxy, BaseAccess {
    using LibProxyAccess for BaseProxyStorage;


    address public immutable factory;
    address public immutable registry;

    
    modifier onlyFactory {
        require(msg.sender == factory, "BaseProxy: caller is not factory");
        _;
    }

    modifier onlyRegistry {
        require(msg.sender == registry, "BaseProxy: caller is not registry");
        _;
    }

    /**
     * @dev Initializes the proxy with the factory and registry addresses.
     */
    constructor(BaseProxyConstructorArgs memory args) {
        require(args.factory != address(0), "BaseProxy: factory is zero address");
        require(args.registry != address(0), "BaseProxy: registry is zero address");
        factory = args.factory;
        registry = args.registry;
    }

    /**
     * convenience function to get the storage for basic proxy
     */
    function _getStorage() internal pure returns (BaseProxyStorage storage bs) {
        return LibBaseProxy.load();
    }

    /**
     * @inheritdoc IBaseProxy
     */
    function getImplementation() external view returns (address) {
        BaseProxyStorage storage bs = _getStorage();
        return bs.implementation;
    }


    /**
     * @dev called by the factory to set the implementation address for this proxy to 
     * delegate to.
     */
    function initProxy(address _implementation) public onlyFactory {
        require(_implementation != address(0), "WorldProxy: implementation is zero address");
        BaseProxyStorage storage bs = _getStorage();
        require(bs.implementation == address(0), "WorldProxy: already initialized");
        bs.implementation = _implementation;
    }

    receive() external payable {
        emit ReceivedFunds(msg.sender, msg.value);
    }

    fallback() external payable {
        BaseProxyStorage storage bs = _getStorage();
        address _impl = bs.implementation;
        require(_impl != address(0), "WorldProxy: implementation not set");
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
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBaseProxy} from './IBaseProxy.sol';
import {BaseProxyStorage, LibProxyAccess, LibBaseProxy} from './libraries/LibBaseProxy.sol';
import {BaseAccess} from './BaseAccess.sol';

struct BaseProxyConstructorArgs {
    address factory;
    address registry;
}

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


    constructor(BaseProxyConstructorArgs memory args) {
        require(args.factory != address(0), "BaseProxy: factory is zero address");
        require(args.registry != address(0), "BaseProxy: registry is zero address");
        factory = args.factory;
        registry = args.registry;
    }

    //must be overridden by proxy implementation
    function fundsReceived(uint256 amount) internal virtual;

    function _getStorage() internal pure returns (BaseProxyStorage storage bs) {
        return LibBaseProxy.load();
    }

    function getImplementation() external view returns (address) {
        BaseProxyStorage storage bs = _getStorage();
        return bs.implementation;
    }


    function initProxy(address _implementation) public onlyFactory {
        require(_implementation != address(0), "WorldProxy: implementation is zero address");
        BaseProxyStorage storage bs = _getStorage();
        require(bs.implementation == address(0), "WorldProxy: already initialized");
        bs.implementation = _implementation;
    }

    //used to upgrade the underlying implementation
    function setImplementation(address impl) public onlyRegistry {
        BaseProxyStorage storage bs = _getStorage();
        bs.implementation = impl;
        emit ImplementationChanged(impl);
    }

    receive() external payable {
        emit ReceivedFunds(msg.sender, msg.value);
        fundsReceived(msg.value);
    }

    fallback() external payable {
        BaseProxyStorage storage bs = _getStorage();
        address _impl = bs.implementation;
        require(_impl != address(0), "WorldProxy: implementation not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }

}
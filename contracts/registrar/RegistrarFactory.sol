// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistrarFactory} from './IRegistrarFactory.sol';
import {BaseFactory} from '../BaseFactory.sol';
import {IBaseProxy} from '../IBaseProxy.sol';
import {IRegistrar} from './IRegistrar.sol';
import {CreateRegistrarArgs} from './IRegistrarRegistry.sol';

interface INextVersion {
    function init(bytes calldata initData) external;
}

contract RegistrarFactory is IRegistrarFactory, BaseFactory {
    
    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    /**
     * @dev Upgrades an existing registrar to the latest version. Called by the registry
     * to carry out the upgrade.
     */
    function upgradeRegistrar(address registrar, bytes calldata initData) external onlyAuthorizedRegistry returns (address) {
        //to upgrade, we just need to change its underlying implementation. 
        //so first, make sure it doesn't already have the latest implementation
        address impl = IBaseProxy(registrar).getImplementation();
        require(impl != implementation, "Already on the latest version");

        //this sets the delegate implementation on the proxy
        IRegistrar(registrar).upgradeComplete(implementation);

        //then we add any new init state to the proxy storage using new impl
        INextVersion(registrar).init(initData);
        return implementation;
    }

    /**
     * @dev Creates a new registrar contract and initializes it with the given data. Called by the registry
     */
    function createRegistrar(CreateRegistrarArgs calldata args) external onlyAuthorizedRegistry returns (address proxy) { 
        proxy = createProxy();
        IBaseProxy(proxy).initProxy(implementation);
        IRegistrar(proxy).init(args);
    }
}
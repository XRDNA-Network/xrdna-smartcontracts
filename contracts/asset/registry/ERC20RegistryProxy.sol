// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../../base-types/BaseProxy.sol';

/**
 * @title ERC20RegistryProxy
 * @dev ERC20RegistryProxy is the proxy contract for the ERC20Registry. It allows the registry logic 
 * to be upgraded without changing the address of the registry or its storage.
 */
contract ERC20RegistryProxy is BaseProxy {
    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}
}
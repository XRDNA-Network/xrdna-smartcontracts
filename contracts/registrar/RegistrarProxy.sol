// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../BaseProxy.sol';

/**
 * @title RegistrarProxy
 * @dev The RegistrarProxy contract is used as the foundational address proxy for all
 * new registrars. Registrar state is held by the proxy and upgraded logic can be applied
 * to retain the state.
 */
contract RegistrarProxy is BaseProxy {

    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}
    
}
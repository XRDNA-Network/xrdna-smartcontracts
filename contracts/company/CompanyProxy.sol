// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../BaseProxy.sol';

/**
 * Proxy for company implementations. This is cloned for each new company instance.
 */
contract CompanyProxy is BaseProxy {
    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}
}
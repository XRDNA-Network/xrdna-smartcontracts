// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../../base-types/BaseProxy.sol';

contract CompanyRegistryProxy is BaseProxy {
    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntityProxy, BaseEntityProxyConstructorArgs} from '../../base-types/entity/BaseEntityProxy.sol';

contract RegistrarProxy is BaseEntityProxy {

    constructor(BaseEntityProxyConstructorArgs memory args) BaseEntityProxy(args) {}

}
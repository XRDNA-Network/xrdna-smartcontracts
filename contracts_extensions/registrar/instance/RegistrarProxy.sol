// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {EntityProxy} from '../../registry/factory/EntityProxy.sol';

contract RegistrarProxy is EntityProxy {

    constructor(address f) EntityProxy(f) {}
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityProxy} from '../../base-types/entity/EntityProxy.sol';

contract AvatarProxy is EntityProxy {
    constructor(address reg) EntityProxy(reg) {}
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityProxy} from '../../base-types/entity/EntityProxy.sol';

/**
 * @title AvatarProxy
 * @dev A proxy contract for Avatar that allows to delegate calls to the Avatar contract while
 * preserving avatar address and storage.
 */
contract AvatarProxy is EntityProxy {
    constructor(address reg) EntityProxy(reg) {}
}
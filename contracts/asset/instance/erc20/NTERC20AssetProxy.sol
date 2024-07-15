// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityProxy} from '../../../base-types/entity/EntityProxy.sol';

/**
 * @title NTERC20AssetProxy
 * @dev Proxy for erc20 asset implementation to allow for future logic upgrades.
 */
contract ERC20AssetProxy is EntityProxy {
    constructor(address reg) EntityProxy(reg) {}
}
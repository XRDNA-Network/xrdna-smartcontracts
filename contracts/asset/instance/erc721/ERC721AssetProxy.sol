// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityProxy} from '../../../base-types/entity/EntityProxy.sol';

/**
 * @title ERC721AssetProxy
 * @dev Proxy for erc721 asset implementation to allow for future logic upgrades.
 */
contract ERC721AssetProxy is EntityProxy {
    constructor(address registry) EntityProxy(registry) {}
}
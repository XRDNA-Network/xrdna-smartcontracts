// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../../BaseProxy.sol';

/**
 * @title NTERC20Proxy
 * @dev This contract is a proxy for the NTERC20 contract.
 * We anticipate that ERC20 assets will be upgraded in the future to support transfers, etc.
 * As such, we need to maintain the underlying state of the asset when upgrades occur. 
 * This proxy allows us to change the final implementation without impacting state. All
 * state is managed by versioned libraries that store V1 state, V2 state, etc. 
 */
contract NTERC20Proxy is BaseProxy {

    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}
}
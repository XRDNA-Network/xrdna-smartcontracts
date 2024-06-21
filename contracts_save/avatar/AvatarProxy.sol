// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../BaseProxy.sol';

/**
 * @title AvatarProxy
 * @dev The AvatarProxy contract is used as the foundational address proxy for all
 * new avatars. Avatar state is held by the proxy and upgraded logic can be applied
 * to retain the state.
 */
contract AvatarProxy is BaseProxy {

    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}
    
}
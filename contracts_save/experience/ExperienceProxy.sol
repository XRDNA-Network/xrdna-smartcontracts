// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../BaseProxy.sol';
import {ExperienceV1Storage, LibExperienceV1Storage} from '../libraries/LibExperienceV1Storage.sol';

/**
 * @title ExperienceProxy
 * @dev Proxy contract for Experience contract. This is cloned for each new Experience instance
 */
contract ExperienceProxy is BaseProxy {

    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}

}
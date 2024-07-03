// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyContstructorArgs} from '../../base-types/BaseProxy.sol';
import {LibTermsOwner} from '../../core-libs/LibTermsOwner.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';

/**
 * @dev WorldRegistry proxy contract that inherits from BaseProxy.
 */
 contract WorldRegistryProxy is BaseProxy {
    
    constructor(BaseProxyContstructorArgs memory args) BaseProxy(args) {
    }
 }
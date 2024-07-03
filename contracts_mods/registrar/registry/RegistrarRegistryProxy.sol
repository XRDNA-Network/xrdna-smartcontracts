// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseCoreProxy, BaseProxyContstructorArgs} from '../../core/proxy/BaseCoreProxy.sol';
import {LibTermsOwner} from '../../libraries/LibTermsOwner.sol';
import {RegistrationTerms} from '../../modules/registration/IRegistration.sol';

/**
 * @dev RegistrarRegistry proxy contract that inherits from BaseCoreProxy.
 */
 contract RegistrarRegistryProxy is BaseCoreProxy {
    
    constructor(BaseProxyContstructorArgs memory args) BaseCoreProxy(args) {
      //set default terms with 30d grace period
      LibTermsOwner.load().terms = RegistrationTerms({
          fee: 0,
          gracePeriodDays: 30,
          coveragePeriodDays: 0
      });
    }
 }
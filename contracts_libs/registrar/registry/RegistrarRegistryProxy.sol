// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyContstructorArgs} from '../../base-types/BaseProxy.sol';
import {LibTermsOwner} from '../../core-libs/LibTermsOwner.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';

/**
 * @dev RegistrarRegistry proxy contract that inherits from BaseCoreProxy.
 */
 contract RegistrarRegistryProxy is BaseProxy {
    bytes32 constant REGISTRAR_TERMS = keccak256("REGISTRAR_TERMS");
    constructor(BaseProxyContstructorArgs memory args) BaseProxy(args) {
      //set default terms with 30d grace period
      LibTermsOwner.load().terms[REGISTRAR_TERMS] = RegistrationTerms({
          fee: 0,
          gracePeriodDays: 30,
          coveragePeriodDays: 0
      });
    }
 }
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ITermsOwnerSupport} from './ITermsOwnerSupport.sol';
import {RegistrationTerms} from '../../../../registry/extensions/registration/interfaces/IRegistration.sol';

interface ITermsOwnerExtension is ITermsOwnerSupport {

    function setTerms(RegistrationTerms calldata terms) external;

    function getTerms() external view returns (RegistrationTerms memory);
}
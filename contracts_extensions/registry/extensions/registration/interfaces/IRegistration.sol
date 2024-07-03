// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from '../../../interfaces/IRegistry.sol';
import {IRegistrationSupport} from './IRegistrationSupport.sol';

struct RegistrationTerms {
    uint256 fee;
    uint256 coveragePeriodDays;
    uint256 gracePeriodDays;
}

struct RegisterEntityArgsNoTermsNoRemoval {
    bool sendTokensToOwner;
    address owner;
    string name;
    bytes initData;
}

struct RegisterEntityArgsNoTermsWithRemoval  {
    bool sendTokensToOwner;
    address owner;
    string name;
    bytes initData;
    uint256 gracePeriodDays;
}

struct RegisterEntityArgsWithTerms {
    bool sendTokensToOwner;
    address owner;
    string name;
    bytes initData;
    RegistrationTerms terms;
}

interface IRegistration is IRegistrationSupport {

    event RegistryAddedEntity(address indexed entity, address indexed by);
    
    function isRegistered(address addr) external view returns (bool);
    function getEntityByName(string calldata name) external view returns (address);

    function registerEntityNoTermsNoRemoval(RegisterEntityArgsNoTermsNoRemoval calldata args) external payable;
    function registerEntityNoTermsWithRemoval(RegisterEntityArgsNoTermsWithRemoval calldata args) external payable;
    function registerEntityWithTerms(RegisterEntityArgsWithTerms calldata args) external payable;
}
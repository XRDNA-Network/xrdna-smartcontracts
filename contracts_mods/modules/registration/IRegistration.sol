// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IModule} from '../IModule.sol';

struct RegistrationTerms {
    uint16 coveragePeriodDays;
    uint16 gracePeriodDays;
    uint256 fee;
}

struct ChangeEntityTermsArgs {
    address entity;
    bytes entitySignature;
    uint256 expiration;
}

interface IRegistration is IModule {
    
    function isRegistered(address addr) external view returns (bool);
    function getEntityByName(string calldata name) external view returns (address);

    function registerEntityNoTermsNoRemoval(address entity) external;
    function registerEntityNoTermsWithRemoval(address entity, uint16 gracePeriodDays) external;
    function registerEntityWithTerms(address entity, RegistrationTerms calldata terms) external;

    /**
     * @dev called by the entity's terms controller to change the terms of the entity. This requires a 
     * signature from an entity signer to authorize the change. The signature is a hash of the terms
     * fees, coverage period, grace period, and an expiration time for the signature.
     */
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external;

    
}
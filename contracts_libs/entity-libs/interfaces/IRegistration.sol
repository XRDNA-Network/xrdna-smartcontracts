// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../core-libs/LibVectorAddress.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';

struct ChangeEntityTermsArgs {
    address entity;
    bytes entitySignature;
    uint256 expiration;
    RegistrationTerms terms;
}

struct RegistrationWithTermsAndVector {
    address entity;
    RegistrationTerms terms;
    VectorAddress vector;
}

interface IRegistration {
    
    function isRegistered(address addr) external view returns (bool);
    function getEntityByName(string calldata name) external view returns (address);

    function registerEntityNoRemoval(RegistrationWithTermsAndVector memory args) external;
    function registerEntityWithRemoval(RegistrationWithTermsAndVector memory args) external;

    /**
     * @dev called by the entity's terms controller to change the terms of the entity. This requires a 
     * signature from an entity signer to authorize the change. The signature is a hash of the terms
     * fees, coverage period, grace period, and an expiration time for the signature.
     */
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external;

    
}
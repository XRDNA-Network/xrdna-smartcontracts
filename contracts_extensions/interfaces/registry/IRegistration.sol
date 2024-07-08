// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';

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

struct CreateEntityArgs {
    bool sendTokensToOwner;
    address owner;
    string name;
    RegistrationTerms terms;
    bytes initData;
    bytes ownerTermsSignature;
    uint256 expiration;
}

interface IRegistration {

    event RegistryAddedEntity(address indexed entity, address indexed owner);
    event RegistryUpgradedEntity(address indexed old, address newVersion);
    
    function isRegistered(address addr) external view returns (bool);
    function getEntityByName(string calldata name) external view returns (address);

     /**
     * @dev called by the entity's terms controller to change the terms of the entity. This requires a 
     * signature from an entity signer to authorize the change. The signature is a hash of the terms
     * fees, coverage period, grace period, and an expiration time for the signature.
     */
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external;

    
}
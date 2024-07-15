// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibRegistration.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

struct CreateCompanyArgs {

    //whether to send tokens to the owner or company contract
    bool sendTokensToOwner;

    //the company owner
    address owner;

    //the globally unique company name
    string name;

    //terms the company is registered with
    RegistrationTerms terms;

    //its derived vector address (based on World vector)
    VectorAddress vector;

    //initialization data
    bytes initData;

    //signature of the owner agreeing to the terms
    bytes ownerTermsSignature;

    //expiration of the signature
    uint256 expiration;
}

interface ICompanyRegistry is IRemovableRegistry, IVectoredRegistry {
    function createCompany(CreateCompanyArgs calldata args) external returns (address);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

struct CreateCompanyArgs {
    bool sendTokensToOwner;
    address owner;
    string name;
    RegistrationTerms terms;
    VectorAddress vector;
    bytes initData;
    bytes ownerTermsSignature;
    uint256 expiration;
}

interface ICompanyRegistry is IRemovableRegistry, IVectoredRegistry {

    function createCompany(CreateCompanyArgs calldata args) external returns (address);
}
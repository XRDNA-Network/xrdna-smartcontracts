// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IRegistration, CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IEntityRemoval} from '../../interfaces/registry/IEntityRemoval.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
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

interface ICompanyRegistry is IRegistration, IRegistryFactory, IAccessControl, IEntityRemoval {
    function worldRegistry() external view returns (address);
    function createCompany(CreateCompanyArgs calldata args) external payable returns (address);
}
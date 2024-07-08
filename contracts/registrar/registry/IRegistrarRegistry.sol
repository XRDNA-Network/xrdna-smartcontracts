// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';

struct CreateNonRemovableRegistrarArgs {
    bool sendTokensToOwner;
    address owner;
    string name;
    bytes initData;
}

struct CreateRegistrarArgs {
    bool sendTokensToOwner;
    address owner;
    uint256 expiration;
    RegistrationTerms terms;
    string name;
    bytes initData;
    bytes ownerTermsSignature;
}

interface IRegistrarRegistry is IRemovableRegistry {

    function createNonRemovableRegistrar(CreateNonRemovableRegistrarArgs calldata args) external payable returns (address);
    function createRemovableRegistrar(CreateRegistrarArgs calldata args) external payable returns (address);
}
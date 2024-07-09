// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';


struct CreateWorldArgs {
    bool sendTokensToOwner;
    address owner;
    uint256 expiration;
    RegistrationTerms terms;
    VectorAddress vector;
    string name;
    bytes initData;
    bytes ownerTermsSignature;
    bytes vectorAuthoritySignature;
}


struct ChangeControllerArgs {
    address entity;
    
    bytes oldControllerSignature;

    bytes entitySignature;

    uint256 expiration;

    RegistrationTerms newTerms;
}


interface IWorldRegistry is IRemovableRegistry, IVectoredRegistry {

    event RegistrarChangedForWorld(address indexed world, address indexed oldRegistrar, address indexed newRegistrar);
    function createWorld(CreateWorldArgs calldata args) external payable returns (address);
    function isVectorAddressAuthority(address a) external view returns (bool);
    function addVectorAddressAuthority(address a) external;
    function removeVectorAddressAuthority(address a) external;
    function changeControllerWithTerms(ChangeControllerArgs calldata args) external;
}
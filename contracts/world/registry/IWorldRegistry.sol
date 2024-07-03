// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IRegistration, CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IEntityRemoval} from '../../interfaces/registry/IEntityRemoval.sol';
import {IControlChange} from '../../interfaces/registry/IControlChange.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

struct CreateWorldArgs {
    bool sendTokensToOwner;
    address owner;
    string name;
    RegistrationTerms terms;
    VectorAddress vector;
    bytes initData;
    bytes ownerTermsSignature;
    uint256 expiration;
}

interface IWorldRegistry is IRegistration, IRegistryFactory, IAccessControl, IEntityRemoval, IControlChange {
    function registrarRegistry() external view returns (address);
    function createWorld(CreateWorldArgs calldata args) external payable returns (address);
    function isVectorAddressAuthority(address a) external view returns (bool);
    function addVectorAddressAuthority(address a) external;
    function removeVectorAddressAuthority(address a) external;
}
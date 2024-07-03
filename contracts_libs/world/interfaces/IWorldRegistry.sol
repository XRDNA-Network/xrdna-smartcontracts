// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from '../../base-types/registry/IRegistry.sol';
import {VectorAddress} from '../../core-libs/LibVectorAddress.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {ChangeControllerArgs} from '../../entity-libs/interfaces/IControlChange.sol';

struct CreateWorldArgs {

    //owner of the world contract
    address owner;

    //world's spatial vector address assigned by registrar
    VectorAddress baseVector;

    //world's globally unique name
    string name;

    //renewal for the newly registered world
    RegistrationTerms terms;

    //signature of the vector address authority that issued the vector address to the registrar
    bytes vectorAuthoritySignature;

    //signature of new world owner agreeing to registration terms
    bytes ownerTermsSignature;

    //signature expiration time in seconds
    uint256 expiration;

    //world contract init data
    bytes initData;
}

interface IWorldRegistry is IRegistry {

    event RegistryChangedTermsController(address indexed world, address indexed newController);

    function createWorld(CreateWorldArgs calldata args) external returns (address);
    function addVectorAddressAuthority(address authority) external;
    function removeVectorAddressAuthority(address authority) external;
    function changeWorldRegistrar(ChangeControllerArgs calldata args) external;
    function isVectorAddressAuthority(address authority) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibRegistration.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';


/**
 * @dev args for creating a new world
 */
struct CreateWorldArgs {
    //whether to send tokens to world owner or contract
    bool sendTokensToOwner;

    //owner of the world contract
    address owner;

    //expiration for terms signature of owner
    uint256 expiration;

    //terms
    RegistrationTerms terms;

    //base vector address for the world
    VectorAddress vector;

    //name of the world
    string name;

    //init data for world contract
    bytes initData;

    //world owner signature of terms
    bytes ownerTermsSignature;

    //new vector addresses require signature of vector signing authority
    bytes vectorAuthoritySignature;
}


/**
 * @dev Worlds can switch registrars. This requires a signature from the current registrar, if 
 * still active, as well as signature of world owner on the new terms.
 */
struct ChangeRegistrarArgs {

    //world contract
    address entity;
    
    //old register signature, if still active
    bytes oldRegistrarSignature;

    //signature of world signer/owner
    bytes entitySignature;

    //expiration for entity signature
    uint256 expiration;

    //new terms
    RegistrationTerms newTerms;
}


/**
 * @title IWorldRegistry
 * @dev IWorldRegistry is the interface for a world registry contract. A world registry creates and manages
 * world contracts.
 */
interface IWorldRegistry is IRemovableRegistry, IVectoredRegistry {

    event RegistrarChangedForWorld(address indexed world, address indexed oldRegistrar, address indexed newRegistrar);
    
    /**
     * @dev Creates a new world contract
     */
    function createWorld(CreateWorldArgs calldata args) external returns (address);

    /**
     * @dev Checks if the given address is a vector address signing authority
     */
    function isVectorAddressAuthority(address a) external view returns (bool);

    /**
     * @dev Adds a new vector address authority
     */
    function addVectorAddressAuthority(address a) external;

    /**
     * @dev Removes a vector address authority
     */
    function removeVectorAddressAuthority(address a) external;

    /**
     * @dev Changes the registrar for a world contract
     */
    function changeRegistrarWithTerms(ChangeRegistrarArgs calldata args) external;
}
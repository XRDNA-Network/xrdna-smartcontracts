// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from './IRegistry.sol';
import {IEntityRemoval} from './IEntityRemoval.sol';
import {RegistrationTerms} from '../../libraries/LibRegistration.sol';


struct ChangeEntityTermsArgs {
    //the entity whose terms are changing
    address entity;

    //signature of one of the entity's signers authorizing the change
    bytes entitySignature;

    //expiration for the signature
    uint256 expiration;

    //new terms
    RegistrationTerms terms;
}

/**
 * @title IRemovableRegistry
 * @dev The IRemovableRegistry contract is the interface for registries that can remove entities.
 */
interface IRemovableRegistry is IRegistry, IEntityRemoval {

    event RegistrarDeactivatedWorld(address indexed world, string reason);
    event RegistrarReactivatedWorld(address indexed world);
    event RegistrarRemovedWorld(address indexed world, string reason);
    
    /**
     * @dev A terms owner can change an entity's terms but only if an entity signer agrees to 
     * the change.
     */
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from './IRegistry.sol';
import {IEntityRemoval} from './IEntityRemoval.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';


struct ChangeEntityTermsArgs {
    address entity;
    bytes entitySignature;
    uint256 expiration;
    RegistrationTerms terms;
}

interface IRemovableRegistry is IRegistry, IEntityRemoval {

    event RegistrarDeactivatedWorld(address indexed world, string reason);
    event RegistrarReactivatedWorld(address indexed world);
    event RegistrarRemovedWorld(address indexed world, string reason);
    
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external;
}
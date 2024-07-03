// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistration, CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IEntityRemoval} from '../../interfaces/registry/IEntityRemoval.sol';

/**
 * @title IRegistrarRegistry
 * @dev IRegistrarRegistry interface that encapsulates all installed functionality for registrar registry. This is 
 * NOT extended on actual registry contract.
 */
interface IRegistrarRegistry is IRegistration, IRegistryFactory, IAccessControl, IEntityRemoval {

    function createRegistrarNoRemoval(CreateEntityArgs calldata args) external payable returns (address);
    function createRemovableRegistrar(CreateEntityArgs calldata args) external payable returns (address);
}
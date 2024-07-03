// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ITermsOwner} from '../../entity-libs/interfaces/ITermsOwner.sol';
import {IRegistry, CreateEntityArgs} from '../../base-types/registry/IRegistry.sol';

interface IRegistrarRegistry is ITermsOwner, IRegistry {

    function createRegistrar(CreateEntityArgs calldata args) external payable returns (address);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistrarWorldRegistration} from '../../interfaces/registrar/IRegistrarWorldRegistration.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';

interface IRegistrar is IRegistrarWorldRegistration, IAccessControl, IRemovableEntity, ITermsOwner {

    function worldRegistry() external view returns (address);
}
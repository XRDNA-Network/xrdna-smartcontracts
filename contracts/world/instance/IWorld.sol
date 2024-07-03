// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IWorldAddCompany} from '../../interfaces/world/IWorldAddCompany.sol';

//TODO: add company and avatar registration interfaces

interface IWorld is IAccessControl, IRemovableEntity, ITermsOwner, IWorldAddCompany {
    event WorldAddedCompany(address indexed company, address indexed owner, VectorAddress vector);
    
    function companyRegistry() external view returns(address);
    function baseVector() external view returns (VectorAddress memory);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IWorldAddCompany} from '../../interfaces/world/IWorldAddCompany.sol';
import {IWorldAddAvatar} from '../../interfaces/world/IWorldAddAvatar.sol';
import {IWorldAddExpForCompany} from '../../interfaces/world/IWorldAddExpForCompany.sol';

interface IWorld is IAccessControl, 
                    IRemovableEntity, 
                    ITermsOwner, 
                    IWorldAddCompany, 
                    IWorldAddAvatar,
                    IWorldAddExpForCompany {
                        
    event WorldAddedCompany(address indexed company, address indexed owner, VectorAddress vector);
    event WorldAddedAvatar(address indexed avatar, address indexed owner);

    event WorldAddedCompany(address indexed company, address indexed owner);
    event WorldDeactivatedCompany(address indexed company, string reason);
    event WorldReactivatedCompany(address indexed company);
    event WorldRemovedCompany(address indexed company, string reason);

    event WorldAddedExperience(address indexed experience, address indexed company, uint256 portalId);
    event WorldDeactivatedExperience(address indexed experience, address indexed company, string reason);
    event WorldReactivatedExperience(address indexed experience, address indexed company);
    event WorldRemovedExperience(address indexed experience, address indexed company, string reason, uint256 portalId);

    function companyRegistry() external view returns(address);
    function avatarRegistry() external view returns(address);
    function experienceRegistry() external view returns(address);
    function baseVector() external view returns (VectorAddress memory);
}
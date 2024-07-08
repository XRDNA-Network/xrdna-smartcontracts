// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';
import {IAvatarRegistry, CreateAvatarArgs} from './IAvatarRegistry.sol';
import {IAvatar} from '../instance/IAvatar.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';

struct AvatarRegistryConstructorArgs {
    address worldRegistry;
    address experienceRegistry;
}   

contract AvatarRegistry is BaseRegistry, IAvatarRegistry {

    using LibVectorAddress for VectorAddress;

    IWorldRegistry public immutable worldRegistry;
    IExperienceRegistry public immutable experienceRegistry;

    modifier onlyActiveWorld {
        require(worldRegistry.isRegistered(msg.sender), "CompanyRegistry: world not registered");
        require(IWorld(msg.sender).isEntityActive(), "CompanyRegistry: world not active");
        _;
    }

    constructor(AvatarRegistryConstructorArgs memory args) {
        require(args.worldRegistry != address(0), "CompanyRegistry: invalid world registry"); 
        require(args.experienceRegistry != address(0), "CompanyRegistry: invalid experience registry");
        worldRegistry = IWorldRegistry(args.worldRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    function createAvatar(CreateAvatarArgs calldata args) external payable onlyActiveWorld returns (address) {
        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "AvatarRegistration: entity implementation not set");
        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "AvatarRegistration: entity cloning failed");

        require(args.startingExperience != address(0), "AvatarRegistration: starting experience required"); 
        require(experienceRegistry.isRegistered(args.startingExperience), "AvatarRegistration: starting experience not registered");

        IAvatar(entity).init(args.name, args.owner, args.startingExperience, args.initData);
        
        _registerNonRemovableEntity(entity);
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(entity).transfer(msg.value);
            }
        }
        emit RegistryAddedEntity(entity, args.owner);

        return entity;
    }
    
}
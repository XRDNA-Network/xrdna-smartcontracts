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
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';
import {Version} from '../../libraries/LibTypes.sol';

struct AvatarRegistryConstructorArgs {
    address worldRegistry;
}   

contract AvatarRegistry is BaseRegistry, IAvatarRegistry {

    using LibVectorAddress for VectorAddress;

    IWorldRegistry public immutable worldRegistry;
    IExperienceRegistry public experienceRegistry;

    modifier onlyActiveWorld {
        require(worldRegistry.isRegistered(msg.sender), "CompanyRegistry: world not registered");
        require(IWorld(msg.sender).isEntityActive(), "CompanyRegistry: world not active");
        _;
    }

    constructor(AvatarRegistryConstructorArgs memory args) {
        require(args.worldRegistry != address(0), "CompanyRegistry: invalid world registry"); 
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    function version() external pure override returns(Version memory) {
        return Version(1,0);
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    function setExperienceRegistry(address registry) external onlyAdmin {
        require(registry != address(0), "AvatarRegistry: invalid registry");
        require(address(experienceRegistry) == address(0), "AvatarRegistry: registry already set");
        experienceRegistry = IExperienceRegistry(registry);
    }

    function createAvatar(CreateAvatarArgs calldata args) external payable onlyActiveWorld returns (address) {
        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "AvatarRegistration: entity implementation not set");
        require(fs.proxyImplementation != address(0), "AvatarRegistration: proxy implementation not set");
        address proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "AvatarRegistration: proxy cloning failed");
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        require(args.startingExperience != address(0), "AvatarRegistration: starting experience required"); 
        require(experienceRegistry.isRegistered(args.startingExperience), "AvatarRegistration: starting experience not registered");

        IAvatar(proxy).init(args.name, args.owner, args.startingExperience, args.initData);
        
        _registerNonRemovableEntity(proxy);
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(proxy).transfer(msg.value);
            }
        }
        emit RegistryAddedEntity(proxy, args.owner);

        return proxy;
    }
    
}
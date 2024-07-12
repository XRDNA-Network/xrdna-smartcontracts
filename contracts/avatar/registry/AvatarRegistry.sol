// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';
import {IAvatarRegistry, CreateAvatarArgs} from './IAvatarRegistry.sol';
import {IAvatar, AvatarInitArgs} from '../instance/IAvatar.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';
import {Version} from '../../libraries/LibVersion.sol';

/**
 * @dev Arguments for the AvatarRegistry constructor
 */
struct AvatarRegistryConstructorArgs {
    address worldRegistry;
}   

/**
 * @title AvatarRegistry
 * @dev A registry for Avatar entities
 */
contract AvatarRegistry is BaseRegistry, IAvatarRegistry {

    using LibVectorAddress for VectorAddress;

    IWorldRegistry public immutable worldRegistry;

    modifier onlyActiveWorld {
        require(worldRegistry.isRegistered(msg.sender), "CompanyRegistry: world not registered");
        require(IWorld(msg.sender).isEntityActive(), "CompanyRegistry: world not active");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    constructor(AvatarRegistryConstructorArgs memory args) {
        require(args.worldRegistry != address(0), "CompanyRegistry: invalid world registry"); 
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    function version() external pure override returns(Version memory) {
        return Version(1,0);
    }

    function canUpOrDowngrade() internal view override {
        //no-op since avatars are not removable
    }

    /**
     * @dev Create a new Avatar entity
     */
    function createAvatar(CreateAvatarArgs calldata args) external onlyActiveWorld nonReentrant returns (address proxy) {
        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "AvatarRegistration: entity implementation not set");
        require(fs.proxyImplementation != address(0), "AvatarRegistration: proxy implementation not set");
        
        //clone avatar proxy for new address space
        proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "AvatarRegistration: proxy cloning failed");

        //set implementation on the new proxy
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        AvatarInitArgs memory aArgs = AvatarInitArgs({
            name: args.name,
            owner: args.owner,
            startingExperience: args.startingExperience,
            initData: args.initData
        });

        //initialize new avatar proxy storage
        IAvatar(proxy).init(aArgs);
        
        //store the new avatar proxy
        _registerNonRemovableEntity(proxy);
        
        emit RegistryAddedEntity(proxy, args.owner);
    }
    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {BaseVectoredRegistry} from '../../base-types/registry/BaseVectoredRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {ICompanyRegistry, CreateCompanyArgs} from './ICompanyRegistry.sol';
import {ICompany, CompanyInitArgs} from '../instance/ICompany.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';

struct CompanyRegistryConstructorArgs {
    address worldRegistry;
}   

/**
 * @title CompanyRegistry
 * @dev A registry for Company entities
 */
contract CompanyRegistry is BaseVectoredRegistry, ICompanyRegistry {

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

    constructor(CompanyRegistryConstructorArgs memory args) {
        require(args.worldRegistry != address(0), "CompanyRegistry: invalid world registry"); 
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    function version() external pure override returns(Version memory) {
        return Version(1, 0);
    }

    /**
     * @dev create a company and register it in this registry.
     */
    function createCompany(CreateCompanyArgs calldata args) external nonReentrant onlyActiveWorld returns (address) {
        
        FactoryStorage storage fs = LibFactory.load();
        
        //make sure we have the necessary implementations set
        require(fs.proxyImplementation != address(0), "CompanyRegistration: proxy implementation not set");
        require(fs.entityImplementation != address(0), "CompanyRegistration: entity implementation not set" );

        //verify that the company owner has agreed to the registration terms
        TermsSignatureVerification memory verification = TermsSignatureVerification({
            terms: args.terms,
            termsOwner: msg.sender,
            owner: args.owner,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);
        
        //clone the proxy and set the entity implementation on the proxy
        address proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "CompanyRegistration: proxy cloning failed");
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        //initialize the storage for the new proxy
        CompanyInitArgs memory cArgs = CompanyInitArgs({
            name: args.name,
            owner: args.owner,
            world: msg.sender,
            vector: args.vector,
            initData: args.initData
        });
        ICompany(proxy).init(cArgs);

        //register the new proxy with registration terms
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: proxy,
            terms: args.terms,
            name: args.name,
            termsOwner: msg.sender,
            vector: args.vector
        });

        LibRegistration.registerRemovableVectoredEntity(regArgs);
        
        emit RegistryAddedEntity(proxy, args.owner);

        return proxy;
    }
}
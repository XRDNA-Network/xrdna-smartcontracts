// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {BaseVectoredRegistry} from '../../base-types/registry/BaseVectoredRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {ICompanyRegistry, CreateCompanyArgs} from './ICompanyRegistry.sol';
import {ICompany} from '../instance/ICompany.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';

struct CompanyRegistryConstructorArgs {
    address worldRegistry;
    address companyRegistry;
}   

contract CompanyRegistry is BaseRemovableRegistry, BaseVectoredRegistry, ICompanyRegistry {

    using LibVectorAddress for VectorAddress;

    IWorldRegistry public immutable worldRegistry;
    address public immutable companyRegistry;

    modifier onlyActiveWorld {
        require(worldRegistry.isRegistered(msg.sender), "CompanyRegistry: world not registered");
        require(IWorld(msg.sender).isEntityActive(), "CompanyRegistry: world not active");
        _;
    }

    constructor(CompanyRegistryConstructorArgs memory args) {
        require(args.worldRegistry != address(0), "CompanyRegistry: invalid world registry"); 
        require(args.companyRegistry != address(0), "CompanyRegistry: invalid company registry");
        worldRegistry = IWorldRegistry(args.worldRegistry);
        companyRegistry = args.companyRegistry;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    function createCompany(CreateCompanyArgs calldata args) external payable onlyActiveWorld returns (address) {
        require(args.terms.gracePeriodDays > 0, "RegistrarRegistrationExt: grace period required for removable registration");
        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "CompanyRegistration: entity implementation not set" );
        
    
        //true,false means needs p > 0, p_sub == 0
        args.vector.validate(true, false);

        TermsSignatureVerification memory verification = TermsSignatureVerification({
            terms: args.terms,
            termsOwner: msg.sender,
            owner: args.owner,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);
        VectorAddress memory v = args.vector;
        require(v.p > 0, "CompanyRegistration: vector address p value must be greater than 0 for company");
        require(v.p_sub == 0, "CompanyRegistration: vector address p_sub must be 0 for company");

        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "CompanyRegistration: entity cloning failed");

        ICompany(entity).init(args.name, msg.sender, args.vector, args.initData);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: entity,
            terms: args.terms,
            vector: args.vector
        });

        LibRegistration.registerRemovableVectoredEntity(regArgs);
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
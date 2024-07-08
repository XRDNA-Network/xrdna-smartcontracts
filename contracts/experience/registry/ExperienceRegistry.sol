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
import {IExperienceRegistry, CreateExperienceArgs} from './IExperienceRegistry.sol';
import {IExperience} from '../instance/IExperience.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';

struct ExperienceRegistryConstructorArgs {
    address companyRegistry;
    address worldRegistry;
    //address portalRegistry
}

contract ExperienceRegistry is BaseRemovableRegistry, BaseVectoredRegistry, IExperienceRegistry {

    using LibVectorAddress for VectorAddress;

    ICompanyRegistry public immutable companyRegistry;
    IWorldRegistry public immutable worldRegistry;

    modifier onlyCompanyWorldChain(address company) {
        //make sure caller is a registered and active world
        require(worldRegistry.isRegistered(msg.sender), "ExperienceRegistry: caller is not a registered world");
        require(IWorld(msg.sender).isEntityActive(), "ExperienceRegistry: caller world is not active");

        //make sure company belongs to world
        address cWorld = ICompany(company).world();
        require(cWorld == msg.sender, "ExperienceRegistry: company does not belong to calling world");
        //make sure company is active
        require(ICompany(company).isEntityActive(), "ExperienceRegistry: company is not active");        
        _;
    }

    constructor(ExperienceRegistryConstructorArgs memory args) {
        require(args.companyRegistry != address(0), 'ExperienceRegistry: Invalid company registry');
        require(args.worldRegistry != address(0), 'ExperienceRegistry: Invalid world registry');
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }


    function createExperience(CreateExperienceArgs calldata args) external payable onlyCompanyWorldChain(args.company) returns (address experience, uint256 portalId) {
        //true,true means needs p and p_sub > 0
        args.vector.validate(true, true);

        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "ExperienceRegistry: entity implementation not set");
        
        experience = LibClone.clone(fs.entityImplementation);
        require(experience != address(0), "RegistrarRegistration: entity cloning failed");

        RegistrationTerms memory terms = RegistrationTerms({
                coveragePeriodDays: 0,
                gracePeriodDays: 1,//set to 1 day so company can remove quickly if needed
                fee: 0
        });

        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: experience,
            terms: terms,
            vector: args.vector
        });

        //FIXME: register portal as well. Get entry fee from newly created experience since it will
        //have decoded it as part of its init args
        portalId = 1; 

        IExperience(experience).init(args.name, args.company, args.vector, args.initData);
        LibRegistration.registerRemovableVectoredEntity(regArgs);
        emit RegistryAddedEntity(experience, args.company);
    }

}
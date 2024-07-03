// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistrationExt} from '../BaseRegistrationExt.sol';
import {ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {CreateEntityArgs, RegistrationWithTermsAndVector} from '../../../interfaces/registry/IRegistration.sol';
import {VectorAddress, LibVectorAddress} from '../../../libraries/LibVectorAddress.sol';
import {LibRegistration, TermsSignatureVerification} from '../../../libraries/LibRegistration.sol';
import {CommonInitArgs, IRegisteredEntity} from '../../../interfaces/entity/IRegisteredEntity.sol';
import {LibFactory, FactoryStorage} from '../../../libraries/LibFactory.sol';
import {LibClone} from '../../../libraries/LibClone.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {IExperienceRegistry, CreateExperienceArgs} from '../../../experience/registry/IExperienceRegistry.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';
import {IWorld} from '../../../world/instance/IWorld.sol';
import {ICompany} from '../../../company/instance/ICompany.sol';
import {RegistrationTerms} from '../../../libraries/LibTypes.sol';

contract ExperienceRegistrationExt is BaseRegistrationExt {

    using LibVectorAddress for VectorAddress;

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.EXPERIENCE_REGISTRATION,
            version: Version(1,0)
        });
    }

     modifier onlyActiveWorld {
        address wr = IExperienceRegistry(address(this)).worldRegistry();
        require(wr != address(0), "ExperienceRegistrationExt: world registry not set");
        IWorldRegistry reg = IWorldRegistry(wr);
        IWorld world = IWorld(msg.sender);
        require(world.isEntityActive(), "CompanyRegistrationExt: world is not active");
        require(reg.isRegistered(msg.sender), "CompanyRegistrationExt: world is not registered");
        _;
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory selectors = new SelectorInfo[](4);

        selectors[0] = SelectorInfo({
            selector: super.getEntityByName.selector,
            name: "getEntityByName(string)"
        });
       selectors[1] = SelectorInfo({
            selector: super.getEntityByVector.selector,
            name: "getEntityByVector(VectorAddress)"
        });
        selectors[2] = SelectorInfo({
            selector: super.isRegistered.selector,
            name: "isRegistered(address)"
        });
        selectors[3] = SelectorInfo({
            selector: this.registerExperience.selector,
            name: "registerExperience(CreateExperienceArgs)"
        });
        
       
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: selectors
        }));
    }


    function register() external onlyRegisteredEntity {
        //no-op
    }

    /**
     * @dev Create and register a new entity with the given arguments.
     */
    function registerExperience(CreateExperienceArgs calldata args) external onlyActiveWorld returns (address experience, uint256 portalId) { 
        
        //true,true means needs p and p_sub > 0
        args.vector.validate(true, true);

        //make sure company belongs to world
        address cWorld = ICompany(args.company).world();
        require(cWorld == msg.sender, "ExperienceRegistration: company does not belong to calling world");

        FactoryStorage storage fs = LibFactory.load();
        experience = LibClone.clone(fs.entityImplementation);
        require(experience != address(0), "RegistrarRegistration: entity cloning failed");

        CommonInitArgs memory initArgs = CommonInitArgs({
            owner: args.company,
            name: args.name,
            termsOwner: args.company,
            registry: address(this),
            initData: args.initData,
            vector: args.vector
        });

        //FIXME: register portal as well. Get entry fee from newly created experience since it will
        //have decoded it as part of its init args
        portalId = 1; 

        IRegisteredEntity(experience).init(initArgs);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: experience,
            terms: RegistrationTerms({
                coveragePeriodDays: 0,
                gracePeriodDays: 1,//set to 1 day so company can remove quickly if needed
                fee: 0
            }),
            vector: args.vector
        });
        LibRegistration.registerEntityWithRemoval(regArgs);
        emit RegistryAddedEntity(experience, args.company);
    }

}
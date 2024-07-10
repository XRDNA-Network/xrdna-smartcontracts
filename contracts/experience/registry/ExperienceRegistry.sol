// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
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
import {IPortalRegistry, AddPortalRequest} from '../../portal/IPortalRegistry.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';

struct ExperienceRegistryConstructorArgs {
    address companyRegistry;
    address worldRegistry;
    //address portalRegistry;
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

    constructor(ExperienceRegistryConstructorArgs memory args)  {
        require(args.companyRegistry != address(0), 'ExperienceRegistry: Invalid company registry');
        require(args.worldRegistry != address(0), 'ExperienceRegistry: Invalid world registry');
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    function version() external pure override returns(Version memory) {
        return Version(1, 0);
    }


    function createExperience(CreateExperienceArgs calldata args) external payable onlyCompanyWorldChain(args.company) returns (address proxy, uint256 portalId) {
        //true,true means needs p and p_sub > 0
        args.vector.validate(true, true);

        FactoryStorage storage fs = LibFactory.load();
        require(fs.proxyImplementation != address(0), "ExperienceRegistry: proxy implementation not set");
        require(fs.entityImplementation != address(0), "ExperienceRegistry: entity implementation not set");
        
        proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "RegistrarRegistration: proxy cloning failed");
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        RegistrationTerms memory terms = RegistrationTerms({
                coveragePeriodDays: 0,
                gracePeriodDays: 1,//set to 1 day so company can remove quickly if needed
                fee: 0
        });

        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: proxy,
            terms: terms,
            vector: args.vector
        });

        IExperience exp = IExperience(proxy);
        exp.init(args.name, args.company, args.vector, args.initData);
        LibRegistration.registerRemovableVectoredEntity(regArgs);
        portalId = exp.initPortal();
        
        emit RegistryAddedEntity(proxy, args.company);
    }

    /**
     * @dev Deactivates an experience. This can only be called by the world registry. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function deactivateExperience(address company, address exp, string calldata reason) external onlyCompanyWorldChain(company) {
        //company must be registered under world and the owner of experience and active
        _verifyOwnershipChain(company, exp);
        LibEntityRemoval.deactivateEntity(IRemovableEntity(exp), reason);
    }

    /**
     * @dev Reactivates an experience. This can only be called by the world registry. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function reactivateExperience(address company, address exp) external onlyCompanyWorldChain(company) {
        //company must be registered under world and the owner of experience and active
        _verifyOwnershipChain(company, exp);
        LibEntityRemoval.reactivateEntity(IRemovableEntity(exp));
    }

    /**
     * @dev Removes an experience from the registry. This can only be called by the world. The company must be
        * the owner of the experience. Company initiates this call through a world so that events are
        * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function removeExperience(address company, address exp, string calldata reason) external onlyCompanyWorldChain(company) returns (uint256 portalId) {
        _verifyOwnershipChain(company, exp);
        LibEntityRemoval.removeEntity(IRemovableEntity(exp), reason);
        portalId = IExperience(exp).portalId();
    }

    


    function _verifyOwnershipChain(address company, address exp) internal view {
        IExperience e = IExperience(exp);
        require(e.company() == company, "ExperienceRemovalExt: company is not the owner of the experience");
    }

}
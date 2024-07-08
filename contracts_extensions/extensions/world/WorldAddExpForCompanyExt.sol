// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibFactory} from '../../libraries/LibFactory.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {IWorldAddExpForCompany, NewExperienceArgs} from '../../interfaces/world/IWorldAddExpForCompany.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {ICompanyRegistry, CreateCompanyArgs} from '../../company/registry/ICompanyRegistry.sol';
import {LibWorld, WorldStorage} from '../../world/instance/LibWorld.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {IExperienceRegistry, CreateExperienceArgs} from '../../experience/registry/IExperienceRegistry.sol';

contract WorldAddExpForCompanyExt is IExtension, IWorldAddExpForCompany {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "WorldAdExpForCompanyExt: restricted to admins");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "WorldAdExpForCompanyExt: restricted to signers");
        _;
    }

    modifier onlyActiveCompany {
        address cr = IWorld(address(this)).companyRegistry();
        require(cr != address(0), "WorldAddExpForCompanyExt: company registry not set");
        ICompanyRegistry registry = ICompanyRegistry(cr);
        require(registry.isRegistered(msg.sender), "WorldAddExpForCompanyExt: company not registered");
        ICompany company = ICompany(msg.sender);
        require(company.isEntityActive(), "WorldAddExpForCompanyExt: company not active");
        require(company.world() == address(this), "WorldAddExpForCompanyExt: company not in world");
        _;
    }

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.WORLD_ADD_EXPERIENCE,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](4);
        sigs[0] = SelectorInfo({
            selector: this.addExperience.selector,
            name: "addExperience(NewExperienceArgs)"
        });
        sigs[1] = SelectorInfo({
            selector: this.deactivateExperience.selector,
            name: "deactivateExperience(address,string)"
        });
        sigs[2] = SelectorInfo({
            selector: this.reactivateExperience.selector,
            name: "reactivateExperience(address)"
        });
        sigs[3] = SelectorInfo({
            selector: this.removeExperience.selector,
            name: "removeExperience(address,string)"
        });
       
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no-op
    }

    /**
     * Initialize any storage related to the extension
     */
    function initStorage(ExtensionInitArgs calldata args) external {
        //nothing to initialize
    }


    /**
     * @dev Registers a new experience contract. Must be called by owning company
     */
    function addExperience(NewExperienceArgs memory args) external payable onlyActiveCompany returns (address experience, uint256 portalId) {
        address e  = IWorld(address(this)).experienceRegistry();
        require(e != address(0), "WorldAddExpForCompanyExt: experience registry not set");
        IExperienceRegistry registry = IExperienceRegistry(e);
        CreateExperienceArgs memory expArgs = CreateExperienceArgs({
            company: msg.sender,
            vector: args.vector,
            name: args.name,
            initData: args.initData
        });
        (experience, portalId) = registry.registerExperience(expArgs);
        emit IWorld.WorldAddedExperience(experience, msg.sender, portalId);
    }

    /**
     * @dev Deactivates an experience. Must be called by owning company
     */
    function deactivateExperience(address experience, string calldata reason) external onlyActiveCompany {
        address e  = IWorld(address(this)).experienceRegistry();
        require(e != address(0), "WorldAddExpForCompanyExt: experience registry not set");
        IExperienceRegistry registry = IExperienceRegistry(e);
        registry.deactivateExperience(msg.sender, experience, reason);
        emit IWorld.WorldDeactivatedExperience(experience, msg.sender, reason);
    }

    /**
     * @dev Reactivates a experience contract. Must be called by owning company
     */
    function reactivateExperience(address experience) external onlyActiveCompany {
        address e  = IWorld(address(this)).experienceRegistry();
        require(e != address(0), "WorldAddExpForCompanyExt: experience registry not set");
        IExperienceRegistry registry = IExperienceRegistry(e);
        registry.reactivateExperience(experience, msg.sender);
    }

    /**
     * @dev Removes a experience contract. Must be called by owning company
     */
    function removeExperience(address experience, string calldata reason) external onlyActiveCompany returns (uint256 portalId) {
       address e  = IWorld(address(this)).experienceRegistry();
        require(e != address(0), "WorldAddExpForCompanyExt: experience registry not set");
        IExperienceRegistry registry = IExperienceRegistry(e);
        portalId = registry.removeExperience(msg.sender, experience, reason);
        emit IWorld.WorldRemovedExperience(experience, msg.sender, reason, portalId);
    }

}
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
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {NewExperienceArgs} from '../../interfaces/world/IWorldAddExpForCompany.sol';
import {ICompanyRegistry, CreateCompanyArgs} from '../../company/registry/ICompanyRegistry.sol';
import {LibWorld, WorldStorage} from '../../world/instance/LibWorld.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {ICompanyAddExperience, AddExperienceArgs} from '../../interfaces/company/ICompanyAddExperience.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {LibCompany, CompanyStorage} from '../../company/instance/LibCompany.sol';

contract CompanyAddExperienceExt is IExtension, ICompanyAddExperience {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "CompanyAddExperienceExt: restricted to admins");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "FactoCompanyAddExperienceExtryExt: restricted to signers");
        _;
    }
     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.COMPANY_ADD_EXPERIENCE,
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
            name: "addExperience(AddExperienceArgs)"
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
     * @dev Add an experience to company's surrounding world. This is called by signers of company.
     */
    function addExperience(AddExperienceArgs memory args) external onlySigner returns (address experience, uint256 portalId) {

        ICompany self = ICompany(address(this));
        VectorAddress memory sub = self.vectorAddress();
        CompanyStorage storage cs = LibCompany.load();
        ++cs.nextPSubValue;
        sub.p_sub = cs.nextPSubValue;
        NewExperienceArgs memory expArgs = NewExperienceArgs({
            vector: sub,
            name: args.name,
            initData: args.initData
        });
        IWorld world = IWorld(self.world());
        (experience, portalId) = world.addExperience(expArgs);
        emit ICompany.CompanyAddedExperience(experience, portalId);
    }

    /**
     * @dev Deactivates an experience contract. Must be called by signer
     */
    function deactivateExperience(address experience, string calldata reason) external onlySigner {
        ICompany self = ICompany(address(this));
        IWorld world = IWorld(self.world());
        world.deactivateExperience(experience, reason);
        emit ICompany.CompanyDeactivatedExperience(experience, reason);
    }

    /**
     * @dev Reactivates an experience contract. Must be called by signers
     */
    function reactivateExperience(address experience) external onlySigner {
        ICompany self = ICompany(address(this));
        IWorld world = IWorld(self.world());
        world.reactivateExperience(experience);
        emit ICompany.CompanyReactivatedExperience(experience);
    }

    /**
     * @dev Removes a experience contract. Must be called by signers
     */
    function removeExperience(address experience, string calldata reason) external onlySigner returns (uint256 portalId) {
        ICompany self = ICompany(address(this));
        IWorld world = IWorld(self.world());
        portalId = world.removeExperience(experience, reason);
        emit ICompany.CompanyRemovedExperience(experience, reason, portalId);
    }


}
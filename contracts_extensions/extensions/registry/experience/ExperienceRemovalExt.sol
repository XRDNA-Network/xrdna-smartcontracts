// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntityRemovalExt} from '../BaseEntityRemovalExt.sol';
import {IRemovableEntity} from '../../../interfaces/entity/IRemovableEntity.sol';
import {LibAccess} from '../../../libraries/LibAccess.sol';
import {LibEntityRemoval} from '../../../libraries/LibEntityRemoval.sol';
import {ExtensionMetadata, IExtension} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {IRegistrarRegistry} from '../../../registrar/registry/IRegistrarRegistry.sol';
import {ITermsOwner} from '../../../interfaces/registry/ITermsOwner.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';
import {ICompanyRegistry} from '../../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../../company/instance/ICompany.sol';
import {IExperience} from '../../../experience/instance/IExperience.sol';
import {IWorld} from '../../../world/instance/IWorld.sol';
import {IRemovableEntity} from '../../../interfaces/entity/IRemovableEntity.sol';

contract ExperienceRemovalExt is  IExtension {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "ExperienceRemovalExt: restricted to admins");
        _;
    }

    modifier onlyActiveWorld() {
        address a = ICompanyRegistry(address(this)).worldRegistry();
        require(a != address(0), "ExperienceRemovalExt: world registry not set");
        IWorldRegistry reg = IWorldRegistry(a);
        require(reg.isRegistered(msg.sender), "ExperienceRemovalExt: caller is not a registered world");
        require(IWorld(msg.sender).isEntityActive(), "ExperienceRemovalExt: world is not active");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.EXPERIENCE_REMOVAL,
            version: Version(1,0)
        });
    }


    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no op
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](3);
        
        sigs[0] = SelectorInfo({
            selector: this.deactivateExperience.selector,
            name: "deactivateExperience(address,address,string)"
        });
        sigs[1] = SelectorInfo({
            selector: this.reactivateExperience.selector,
            name: "reactivateExperience(address,address)"
        });
        sigs[2] = SelectorInfo({
            selector: this.removeExperience.selector,
            name: "removeExperience(address,address,string)"
        });

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    function _verifyOwnershipChain(address company, address exp) internal view {
        ICompany comp = ICompany(company);
        require(comp.world() == msg.sender, "ExperienceRemovalExt: company not in calling world");
        require(comp.isEntityActive(), "ExperienceRemovalExt: company is not active");
        IExperience e = IExperience(exp);
        require(e.company() == company, "ExperienceRemovalExt: company is not the owner of the experience");
    }

     /**
     * @dev Deactivates an experience. This can only be called by the world registry. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function deactivateExperience(address company, address exp, string calldata reason) external onlyActiveWorld {
        //company must be registered under world and the owner of experience and active
        _verifyOwnershipChain(company, exp);
        LibEntityRemoval.deactivateEntity(IRemovableEntity(exp), reason);
    }

    /**
     * @dev Reactivates an experience. This can only be called by the world registry. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function reactivateExperience(address company, address exp) external onlyActiveWorld {
        //company must be registered under world and the owner of experience and active
        _verifyOwnershipChain(company, exp);
        LibEntityRemoval.reactivateEntity(IRemovableEntity(exp));
    }

    /**
     * @dev Removes an experience from the registry. This can only be called by the world. The company must be
        * the owner of the experience. Company initiates this call through a world so that events are
        * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function removeExperience(address company, address exp, string calldata reason) external onlyActiveWorld returns (uint256 portalId) {
        _verifyOwnershipChain(company, exp);
        LibEntityRemoval.removeEntity(IRemovableEntity(exp), reason);
        //FIXME: need to remove portal and get its id
        return 1;
    }
}
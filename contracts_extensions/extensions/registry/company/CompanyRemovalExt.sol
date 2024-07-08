// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseEntityRemovalExt} from '../BaseEntityRemovalExt.sol';
import {IRemovableEntity} from '../../../interfaces/entity/IRemovableEntity.sol';
import {LibAccess} from '../../../libraries/LibAccess.sol';
import {LibEntityRemoval} from '../../../libraries/LibEntityRemoval.sol';
import {ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {IRegistrarRegistry} from '../../../registrar/registry/IRegistrarRegistry.sol';
import {ITermsOwner} from '../../../interfaces/registry/ITermsOwner.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';
import {ICompanyRegistry} from '../../../company/registry/ICompanyRegistry.sol';

contract CompanyRemovalExt is BaseEntityRemovalExt {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "CompanyRemovalExt: restricted to admins");
        _;
    }

    modifier onlyActiveWorld(IRemovableEntity entity) {
        address a = ICompanyRegistry(address(this)).worldRegistry();
        require(a != address(0), "CompanyRemovalExt: world registry not set");
        IWorldRegistry reg = IWorldRegistry(a);
        require(reg.isRegistered(msg.sender), "CompanyRemovalExt: caller is not a registered world");
        require(ITermsOwner(msg.sender).isStillActive(), "CompanyRemovalExt: world is not active");
        require(entity.termsOwner() == msg.sender, "CompanyRemovalExt: caller is not the company's terms owner");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.COMPANY_REMOVAL,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](13);
        sigs[0] = SelectorInfo({
            selector: super.getEntityTerms.selector,
            name: "getEntityTerms(address)"
        });
        sigs[1] = SelectorInfo({
            selector: super.canBeDeactivated.selector,
            name: "canBeDeactivated(address)"
        });
        sigs[2] = SelectorInfo({
            selector: super.canBeRemoved.selector,
            name: "canBeRemoved(address)"
        });
        sigs[3] = SelectorInfo({
            selector: super.enforceDeactivation.selector,
            name: "enforceDeactivation(address)"
        });
        sigs[4] = SelectorInfo({
            selector: super.enforceRemoval.selector,
            name: "enforceRemoval(address)"
        });
        sigs[5] = SelectorInfo({
            selector: super.getLastRenewal.selector,
            name: "getLastRenewal(address)"
        });
        sigs[6] = SelectorInfo({
            selector: super.getExpiration.selector,
            name: "getExpiration(address)"
        });
        sigs[7] = SelectorInfo({
            selector: super.isExpired.selector,
            name: "isExpired(address)"
        });
        sigs[8] = SelectorInfo({
            selector: super.isInGracePeriod.selector,
            name: "isInGracePeriod(address)"
        });
        sigs[9] = SelectorInfo({
            selector: super.renewEntity.selector,
            name: "renewEntity(address)"
        });
        sigs[10] = SelectorInfo({
            selector: this.deactivateEntity.selector,
            name: "deactivateEntity(address,string)"
        });
        sigs[11] = SelectorInfo({
            selector: this.reactivateEntity.selector,
            name: "reactivateEntity(address)"
        });
        sigs[12] = SelectorInfo({
            selector: this.removeEntity.selector,
            name: "removeEntity(address,string)"
        });

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

     /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) external onlyActiveWorld(entity) {
        LibEntityRemoval.deactivateEntity(entity, reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) external onlyActiveWorld(entity) {
        LibEntityRemoval.reactivateEntity(entity);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external onlyActiveWorld(entity)   {
        LibEntityRemoval.removeEntity(entity, reason);
    }
}
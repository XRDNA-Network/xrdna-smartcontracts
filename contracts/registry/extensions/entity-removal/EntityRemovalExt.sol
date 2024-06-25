// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtension} from "../../../core/extensions/BaseExtension.sol";
import {ExtensionMetadata} from '../../../core/extensions/IExtension.sol';
import {SelectorArgs, AddSelectorArgs, LibExtensions} from '../../../core/LibExtensions.sol';
import {IRemovableEntity} from './interfaces/IRemovableEntity.sol';
import {LibStringCase} from '../../../libraries/common/LibStringCase.sol';
import {IEntityRemovalExtension} from './interfaces/IEntityRemovalExtension.sol';
import {IRegistry} from '../../interfaces/IRegistry.sol';
import {RegistrationStorage, TermedRegistration, LibRegistration} from '../../libraries/LibRegistration.sol';
import {ITermsOwner} from '../../../entity/extensions/terms-owner/interfaces/ITermsOwner.sol';
import {RegistrationTerms} from '../../extensions/registration/interfaces/IRegistration.sol';

contract EntityRemovalExt is BaseExtension, IEntityRemovalExtension {
    using LibStringCase for string;

    uint256 constant DAY = 1 days;

    modifier onlyActiveTermsOwner {
        //this forces shell to have implemented this function
        require(IRegistry(address(this)).isActiveTermsOwner(msg.sender), "EntityRemoval: caller is not an active terms owner");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.core.EntityRemovalExt", 1);
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) public {
        SelectorArgs[] memory selectors = _buildSelectors();
        
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            selectors: selectors,
            impl: myAddress
        }));
    }

    function _buildSelectors() private pure returns (SelectorArgs[] memory args) {
        args = new SelectorArgs[](12);
        args[0] = SelectorArgs({
            selector: this.getLastRenewal.selector,
            isVirtual: false
        });
        args[1] = SelectorArgs({
            selector: this.getExpiration.selector, 
            isVirtual: false
        });
        args[2] = SelectorArgs({
            selector: this.isExpired.selector,
            isVirtual: false
        });
        args[3] = SelectorArgs({
            selector: this.isInGracePeriod.selector,
            isVirtual: false
        });
        args[4] = SelectorArgs({
            selector: this.renewEntity.selector,
            isVirtual: false
        });
        args[5] = SelectorArgs({
            selector: this.deactivateEntity.selector,
            isVirtual: false
        });
        args[6] = SelectorArgs({
            selector: this.reactivateEntity.selector,
            isVirtual: false
        });
        args[7] = SelectorArgs({
            selector: this.removeEntity.selector,
            isVirtual: false
        });
        args[8] = SelectorArgs({
            selector: this.canBeDeactivated.selector,
            isVirtual: false
        });
        args[9] = SelectorArgs({
            selector: this.canBeRemoved.selector,
            isVirtual: false
        });
        args[10] = SelectorArgs({
            selector: this.enforceDeactivation.selector,
            isVirtual: false
        });
        args[11] = SelectorArgs({
            selector: this.enforceRemoval.selector,
            isVirtual: false
        });
        return args;
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress, uint256 currentVersion) public {
        //no-op
    }

    /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) public onlyActiveTermsOwner {
        
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];
        require(address(reg.owner) == msg.sender, "EntityRemoval: caller is not the entity's registration owner"); 
        reg.deactivationTime = block.timestamp;
        entity.deactivate(reason);
        emit RegistryDeactivatedEntity(address(entity), reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) public onlyActiveTermsOwner {
        
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];
        require(address(reg.owner) == msg.sender, "EntityRemoval: caller is not the entity's registration owner");
        reg.deactivationTime = 0;
        entity.reactivate();
        emit RegistryReactivatedEntity(address(entity));
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) public onlyActiveTermsOwner {
        
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];
        require(address(reg.owner) == msg.sender, "EntityRemovalExt: caller is not the entity's registration owner");
        require(reg.deactivationTime > 0, "EntityRemovalExt: entity must be deactivated before removal");
        require(block.timestamp > reg.deactivationTime + (reg.terms.gracePeriodDays * DAY), "EntityRemovalExt: deactivation grace period has not expired");
        entity.remove(reason);
        delete rs.removableRegistrations[address(entity)];
        string memory nm = entity.name().lower();
        delete rs.registrationsByName[nm];
        emit RegistryRemovedEntity(address(entity), reason);
    }

    //FIXME: add function for controller to change terms of an entity.

    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[addr];
        if(reg.terms.coveragePeriodDays == 0) {
            return false;
        }
        uint256 expTime = reg.lastRenewed + (reg.terms.coveragePeriodDays * DAY);
        uint256 graceTime = expTime + (reg.terms.gracePeriodDays * DAY);
        return block.timestamp >= expTime && block.timestamp < graceTime;
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[addr];
        if(reg.terms.coveragePeriodDays == 0) {
            return false;
        }
        if(reg.deactivationTime == 0){
            return false;
        }
        uint256 expTime = reg.deactivationTime + (reg.terms.coveragePeriodDays * DAY);
        return block.timestamp >= expTime;
    }

    /**
     * @dev Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    function enforceDeactivation(IRemovableEntity addr) public {
        require(canBeDeactivated(address(addr)), "EntityRemovalExt: Entity cannot be deactivated");
        addr.deactivate("Deactivation enforced due to terms expiration");
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[address(addr)];
        tr.deactivationTime = block.timestamp;
        emit RegistryEnforcedDeactivation(address(addr));
    }

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) public {
        address addr = address(e);
        require(canBeRemoved(addr), "StatusChangesExt: entity cannot be removed");
        RegistrationStorage storage rs = LibRegistration.load();
        e.remove("Removal enforced due to terms expiration");
        delete rs.removableRegistrations[addr];
        string memory nm = e.name().lower();
        delete rs.registrationsByName[nm];
        emit RegistryEnforcedRemoval(addr);
    }


    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) external view returns (uint256) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        return tr.lastRenewed;
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        if(tr.terms.coveragePeriodDays == 0){
            return 0;
        }
        return tr.lastRenewed + tr.terms.coveragePeriodDays * DAY;
    }

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) external view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        if(tr.terms.coveragePeriodDays == 0){
            return false;
        }
        return block.timestamp > tr.lastRenewed + tr.terms.coveragePeriodDays * DAY;
    }

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) external view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        if(tr.terms.coveragePeriodDays == 0){
            return false;
        }
        uint256 exTime = tr.lastRenewed + tr.terms.coveragePeriodDays * DAY;
        uint graceExp = exTime + tr.terms.gracePeriodDays * DAY;
        bool expired = block.timestamp > exTime;
        return expired && block.timestamp < graceExp;
    }

    /**
     * @dev Renew an entity by paying the renewal fee.
     */
    function renewEntity(address addr) external payable {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        require(tr.terms.coveragePeriodDays > 0, "RenewalExt: Entity does not have renewal terms");
        ITermsOwner termsOwner = ITermsOwner(tr.owner);
        RegistrationTerms memory newTerms = termsOwner.getTerms();
        require(newTerms.gracePeriodDays > 0, "RenewalExt: Registration terms require a grace period even when no coverage period exists. This is to provide a removal grace period for entities");
        uint256 fee = newTerms.fee;
        require(msg.value >= fee, "RenewalExt: Insufficient funds for new terms");
        tr.terms = newTerms;
        tr.lastRenewed = block.timestamp;
        tr.deactivationTime = 0;
        uint256 refund = msg.value - fee;
        if(refund > 0){
            payable(msg.sender).transfer(refund);
        }
        payable(address(tr.owner)).transfer(fee);
        emit EntityRegistrationRenewed(addr, msg.sender);
    }

}
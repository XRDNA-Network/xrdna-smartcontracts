// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IEntityRemoval} from "./IEntityRemoval.sol";
import {ModuleVersion} from '../../IModule.sol';
import {IModuleRegistry} from '../../../core/IModuleRegistry.sol';
import {IRemovableEntity} from '../../registration/IRemovableEntity.sol';
import {ITermsOwner} from '../../registration/ITermsOwner.sol';
import {RegistrationTerms} from '../../registration/IRegistration.sol';
import {LibStringCase} from '../../../libraries/LibStringCase.sol';
import {RegistrationStorage, TermedRegistration, LibRegistrationStorage} from '../../registration/LibRegistrationStorage.sol';

/**
 * @title EntityRemovalModule
 * @dev A module for removing entities from the registry. Entities can be deactivated by the terms owner
 * and then removed after a grace period. The terms owner can also renew the entity to extend the coverage period.
 * WARNING: This module assumes that the delegatecalling contract has made the necessary access checks and status checks of
 * terms owners prior to delegate calling this module.
 */
contract EntityRemovalModule is IEntityRemoval {

    using LibStringCase for string;

    uint256 constant DAY = 1 days;
    string public constant name = "IEntityRemoval";


    function version() public pure override returns (ModuleVersion memory) {
        return ModuleVersion(1, 0);
    }

    /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) public {
        
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];
        require(address(reg.owner) == msg.sender, "EntityRemoval: caller is not the entity's registration owner"); 
        reg.deactivationTime = block.timestamp;
        entity.deactivate(reason);
        emit RegistryDeactivatedEntity(address(entity), reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) public {
        
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
    function removeEntity(IRemovableEntity entity, string calldata reason) public {
        
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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

    /**
     * @dev Returns the terms for the given entity address
     */
    function getEntityTerms(address addr) public view override returns (RegistrationTerms memory) {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        return rs.removableRegistrations[addr].terms;
    }

    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        return tr.lastRenewed;
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256) {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
        RegistrationStorage storage rs = LibRegistrationStorage.load();
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
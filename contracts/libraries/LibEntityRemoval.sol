// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IEntityRemoval} from "../interfaces/registry/IEntityRemoval.sol";
import {IRemovableEntity} from '../interfaces/entity/IRemovableEntity.sol';
import {RegistrationTerms} from './LibRegistration.sol';
import {LibStringCase} from './LibStringCase.sol';
import {VectorAddress} from './LibVectorAddress.sol';
import {RegistrationStorage, TermedRegistration, LibRegistration} from './LibRegistration.sol';

/**
 * @title LibEntityRemoval
 * @dev Library for managing the removal of entities from the registry. Entities can be deactivated, reactivated, and removed
 * by the terms owner. Entities can also be enforced to deactivate or remove by anyone if they are outside the grace period.
 */
library LibEntityRemoval {

    using LibStringCase for string;

    uint256 constant DAY = 1 days;

    modifier nonReentrant {
        RegistrationStorage storage rs = LibRegistration.load();
        require(rs.reentrancyLock == 0, "EntityRemovalExt: reentrant call");
        rs.reentrancyLock = 1;
        _;
        rs.reentrancyLock = 0;
    }

    /** 
      @dev Intiiated by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) public nonReentrant {
        
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];

        //establish the grace period starting time
        reg.deactivationTime = block.timestamp;

        //tell the entity to deactivate itself for the given reason
        entity.deactivate(reason);
        emit IEntityRemoval.RegistryDeactivatedEntity(address(entity), reason);
    }

    /**
     * @dev Initiated by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) public nonReentrant {
        
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];

        //clear the grace period clock
        reg.deactivationTime = 0;

        //tell the entity to reactivate itself
        entity.reactivate();
        emit IEntityRemoval.RegistryReactivatedEntity(address(entity));
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) public nonReentrant {
        _removeEntity(entity, reason);
    }

    function _removeEntity(IRemovableEntity entity, string calldata reason) private {
        
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];

        //make sure we've established the grace period countdown (i.e. deactivated first)
        require(reg.deactivationTime > 0, "EntityRemovalExt: entity must be deactivated before removal");
        
        //make sure we've exhausted the grace period
        require(block.timestamp > reg.deactivationTime + (reg.terms.gracePeriodDays * DAY), "EntityRemovalExt: deactivation grace period has not expired");
        
        //tell the entity they're being removed
        entity.remove(reason);

        //delete the entries
        delete rs.removableRegistrations[address(entity)];
        string memory nm = entity.name().lower();
        delete rs.registrationsByName[nm];
        emit IEntityRemoval.RegistryRemovedEntity(address(entity), reason);
    }

    function removeEntityWithVector(IRemovableEntity entity, VectorAddress memory vector, string calldata reason) public nonReentrant {
        _removeEntity(entity, reason);
        LibRegistration.removeVectorRegistration(vector);
        emit IEntityRemoval.RegistryRemovedEntity(address(entity), reason);
    }

    /**
     * @dev Returns the terms for the given entity address
     */
    function getEntityTerms(address addr) public view returns (RegistrationTerms memory) {
        RegistrationStorage storage rs = LibRegistration.load();
        return rs.removableRegistrations[addr].terms;
    }

    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[addr];

        //If there are no actual registration terms or coverage period, then 
        //entity cannot be forced into deactivation.
        if(reg.terms.coveragePeriodDays == 0) {
            return false;
        }

        //but if the terms have expired
        uint256 expTime = reg.lastRenewed + (reg.terms.coveragePeriodDays * DAY);

        //then it should be allowable to deactivate the entity
        return block.timestamp >= expTime;
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[addr];

        //no registration coverage means cannot be removed
        if(reg.terms.coveragePeriodDays == 0) {
            return false;
        }

        //if the entity was never deactivated, then cannot be removed
        if(reg.deactivationTime == 0){
            return false;
        }

        //can only be removed if grace period has expired
        uint256 expTime = reg.deactivationTime + (reg.terms.gracePeriodDays * DAY);
        return block.timestamp >= expTime;
    }

    /**
     * @dev Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    function enforceDeactivation(IRemovableEntity addr) public nonReentrant {

        //make sure we can force deactivation
        require(canBeDeactivated(address(addr)), "EntityRemovalExt: Entity cannot be deactivated");

        //tell the entity to deactivate itself
        addr.deactivate("Deactivation enforced due to terms expiration");

        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[address(addr)];

        //start the grace period countdown
        tr.deactivationTime = block.timestamp;
        emit IEntityRemoval.RegistryEnforcedDeactivation(address(addr));
    }

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) public nonReentrant {
        _enforceRemoval(e);

    }

    function _enforceRemoval(IRemovableEntity e) private {
        address addr = address(e);
        //make sure we can force removal
        require(canBeRemoved(addr), "StatusChangesExt: entity cannot be removed");
        RegistrationStorage storage rs = LibRegistration.load();

        //tell entity that it's being removed
        e.remove("Removal enforced due to terms expiration");

        //delete entries
        delete rs.removableRegistrations[addr];
        string memory nm = e.name().lower();
        delete rs.registrationsByName[nm];
        emit IEntityRemoval.RegistryEnforcedRemoval(addr);
    }

    function enforceRemovalWithVector(IRemovableEntity e, VectorAddress memory vector) public nonReentrant {
        _enforceRemoval(e);
        LibRegistration.removeVectorRegistration(vector);
        emit IEntityRemoval.RegistryEnforcedRemoval(address(e));
    }

    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) public view returns (uint256) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        return tr.lastRenewed;
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) public view returns (uint256) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];

        //no coverage means no expiration possible
        if(tr.terms.coveragePeriodDays == 0){
            return 0;
        }
        //otherwise expiration is the last renewal time plus the coverage period
        return tr.lastRenewed + tr.terms.coveragePeriodDays * DAY;
    }

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) public view returns (bool) {
        uint256 exp = getExpiration(addr);

        //is the current block time is greater than the expiration time
        return exp > 0 && block.timestamp >= exp;
    }

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];
        //no coverage, no grace period
        if(tr.terms.coveragePeriodDays == 0){
            return false;
        }

        //expiration time of the registration
        uint256 exTime = tr.lastRenewed + tr.terms.coveragePeriodDays * DAY;

        //the grace period
        uint graceExp = exTime + tr.terms.gracePeriodDays * DAY;

        //we're in the grace period if the coverage has expired but we're still within the grace period
        bool expired = block.timestamp >= exTime;
        return expired && block.timestamp < graceExp;
    }

    /**
     * @dev Renew an entity by paying the renewal fee.
     */
    function renewEntity(address addr) public nonReentrant {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[addr];

        //no renewal allowed if no coverage period
        require(tr.terms.coveragePeriodDays > 0, "RenewalExt: Entity does not have renewal terms");

        //make sure sufficient fee included in registration renewal.
        uint256 fee = tr.terms.fee;
        require(msg.value >= fee, "RenewalExt: Insufficient funds for new terms");

        //reset the entity's registration time
        tr.lastRenewed = block.timestamp;

        if(tr.deactivationTime > 0){
            //if previously deactivated, reactivate the entity
            IRemovableEntity(addr).reactivate();
            //clear deactivation.
            tr.deactivationTime = 0;
        }
        
        uint256 refund = 0;
        unchecked {
            refund = msg.value - fee;
        }

        //send funds to the terms owner for the renewal.
        payable(tr.owner).transfer(fee);
        if(refund > 0) {
            //return any excess funds to the sender
            payable(msg.sender).transfer(refund);
        }
        
        emit IEntityRemoval.EntityRegistrationRenewed(addr, msg.sender);
    }

}
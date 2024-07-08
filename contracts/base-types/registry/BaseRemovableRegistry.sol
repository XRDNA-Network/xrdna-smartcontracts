// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from './BaseRegistry.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {ChangeEntityTermsArgs} from '../../interfaces/registry/IRemovableRegistry.sol';
import {LibRegistration} from '../../libraries/LibRegistration.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';

abstract contract BaseRemovableRegistry is BaseRegistry, IRemovableRegistry {

    modifier onlyEntityOwner(address entity) {
        IRemovableEntity e = IRemovableEntity(entity);
        require(e.termsOwner() == msg.sender, "BaseRemovableRegistry: caller is not the entity's terms owner");
        ITermsOwner to = ITermsOwner(msg.sender);
        require(to.isStillActive(), "BaseRemovableRegistry: caller is not active");
        _;
    }

    function deactivateEntity(IRemovableEntity entity, string calldata reason) external onlyEntityOwner(address(entity)) override {
        LibEntityRemoval.deactivateEntity(entity, reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) external onlyEntityOwner(address(entity)) override {
        LibEntityRemoval.reactivateEntity(entity);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external onlyEntityOwner(address(entity)) override {
        LibEntityRemoval.removeEntity(entity, reason);
    }

    /**
     * @dev Returns the terms for the given entity address
     */
    function getEntityTerms(address addr) public view returns (RegistrationTerms memory) {
        return LibEntityRemoval.getEntityTerms(addr);
    }

    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) public view returns (bool) {
        return LibEntityRemoval.canBeDeactivated(addr);
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) public view returns (bool) {
        return LibEntityRemoval.canBeRemoved(addr);
    }

    /**
     * @dev Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    function enforceDeactivation(IRemovableEntity addr) public {
        LibEntityRemoval.enforceDeactivation(addr);
    }

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) public {
        LibEntityRemoval.enforceRemoval(e);
    }

    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) public view returns (uint256) {
        return LibEntityRemoval.getLastRenewal(addr);
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) public view returns (uint256) {
        return LibEntityRemoval.getExpiration(addr);
    }

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) public view returns (bool) {
        return LibEntityRemoval.isExpired(addr);
    }

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) public view returns (bool) {
        return LibEntityRemoval.isInGracePeriod(addr);
    }

    /**
     * @dev Renew an entity by paying the renewal fee.
     */
    function renewEntity(address addr) public payable {
        LibEntityRemoval.renewEntity(addr);
    }

    function changeEntityTerms(ChangeEntityTermsArgs calldata args) public onlyEntityOwner(args.entity) override{
        LibRegistration.changeEntityTerms(args);
    }

    function _registerRemovableEntity(address entity, RegistrationTerms memory terms) internal {
        LibRegistration.registerRemovableEntity(entity, terms);
    }
}
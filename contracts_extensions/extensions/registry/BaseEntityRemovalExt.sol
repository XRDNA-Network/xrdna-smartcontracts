// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version, RegistrationTerms} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRegistration, RegistrationStorage,TermedRegistration} from '../../libraries/LibRegistration.sol';
import {IEntityRemoval} from '../../interfaces/registry/IEntityRemoval.sol';
import {LibExtensions, AddSelectorArgs} from '../../libraries/LibExtensions.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';

abstract contract BaseEntityRemovalExt is IExtension, IEntityRemoval {

    
    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) public {
        //no-op
    }

    /**
     * Initialize any storage related to the extension
     */
    function initStorage(ExtensionInitArgs calldata args) public {
        //nothing to initialize
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

}
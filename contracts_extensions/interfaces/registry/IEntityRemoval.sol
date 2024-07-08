// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableEntity} from '../entity/IRemovableEntity.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';

interface IEntityRemoval {

    event RegistryDeactivatedEntity(address indexed entity, string reason);
    event RegistryReactivatedEntity(address indexed entity);
    event RegistryRemovedEntity(address indexed entity, string reason);
    event RegistryEnforcedDeactivation(address indexed entity);
    event RegistryEnforcedRemoval(address indexed entity);
    event EntityRegistrationRenewed(address indexed entity, address indexed by);
    
    /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) external;

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) external;

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external;

    /**
     * @dev Returns the terms for the given entity address
     */
    function getEntityTerms(address addr) external view returns (RegistrationTerms memory);

    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) external view returns (bool);

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) external view returns (bool);

    /**
     * @dev Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    function enforceDeactivation(IRemovableEntity addr) external;

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) external;

    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) external view returns (uint256);

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256);

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) external view returns (bool);

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) external view returns (bool);

    /**
     * @dev Renew an entity by paying the renewal fee.
     */
    function renewEntity(address addr) external payable;
}
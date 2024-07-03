// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableEntity} from '../../modules/registration/IRemovableEntity.sol';
import {IEntityRemoval} from '../../modules/entity/removal/IEntityRemoval.sol';
import {LibDelegation} from '../../core/LibDelegation.sol';
import {RegistrationTerms} from '../../modules/registration/IRegistration.sol';

interface IProvideRemoval {
    function entityRemovalLogic() external view returns (IEntityRemoval);
}

library LibEntityRemoval {

    using LibDelegation for address;
    using LibEntityRemoval for IEntityRemoval;

    function _getRemoval() internal view returns (IEntityRemoval) {
        return IProvideRemoval(address(this)).entityRemovalLogic();
    }

    /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) external {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.deactivateEntity.selector, entity, reason);
        address(entry).dCall(data);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) external {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.reactivateEntity.selector, entity);
        address(entry).dCall(data);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.removeEntity.selector, entity, reason);
        address(entry).dCall(data);
    }

    function getEntityTerms(address addr) external view returns (RegistrationTerms memory) {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.getEntityTerms.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (RegistrationTerms));
    }
    
    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) external view returns (bool) {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.canBeDeactivated.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (bool));
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) external view returns (bool) {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.canBeRemoved.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (bool));
    }

    /**
     * @dev Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    function enforceDeactivation(IRemovableEntity addr) external {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.enforceDeactivation.selector, addr);
        address(entry).dCall(data);
    }

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) external {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.enforceRemoval.selector, e);
        address(entry).dCall(data);
    }


    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) external view returns (uint256) {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.getLastRenewal.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (uint256));
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256) {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.getExpiration.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (uint256));
    }

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) external view returns (bool) {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.isExpired.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (bool));
    }

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) external view returns (bool) {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.isInGracePeriod.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (bool));
    }

    /**
     * @dev Renew an entity by paying the renewal fee.
     */
    function renewEntity(address addr) external {
        IEntityRemoval entry = _getRemoval();
        bytes memory data = abi.encodeWithSelector(IEntityRemoval.renewEntity.selector, addr);
        address(entry).dCall(data);
    }
}
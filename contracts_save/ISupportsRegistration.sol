// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBaseAccess} from './IBaseAccess.sol';

import {RegistrationTerms} from './libraries/LibRegistration.sol';


/**
    * @title ISupportsRegistration
    * @dev Interface for contracts that support registration. Registration is a way to
    * control access with fees and expiration periods.
 */
interface ISupportsRegistration {

    event AddressDeactivated(address indexed entity);
    event AddressRemoved(address indexed entity);
    event AddressReactivated(address indexed entity);
    
    /**
     * @dev Sets the registration terms for the contract for the given terms type hash. 
     * Registration terms can have different plans for different types of entities. The type
     * labels the terms so they can be applied when different entities register or renew.
     * This can only be called by the admin.
     */
    function setTerms(bytes32 termsType, RegistrationTerms memory terms) external;

    /**
     * @dev Returns the current registration terms for the contract. Any registered 
     * entity prior to this call is grandfathered into previous terms until renewal, if
     * applicable. If no terms were set when registered, the entity will never have to renew
     * and will always be considered registered.
     */
    function getTerms(bytes32 termsType) external view returns (RegistrationTerms memory);

    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) external view returns (uint256);

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256);

    /**
     * @dev Check whether an address is registered.
     */
    function isRegistered(address addr) external view returns (bool);

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) external view returns (bool);

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) external view returns (bool);

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
     * @dev Forces deactivation of an entity. Can be called by anyone but will only
        * succeed if the entity is inside the grace period
     */
    function forceDeactivation(address world) external;

    /**
     * @dev Forces removal of an entity. Can be called by anyone but will only
        * succeed if it is outside the grace period
     */
    function forceRemoval(address world) external;

    /**
     * @dev Withdraws any funds in the contract. This can only be called by the admin.
     */
    function withdraw(uint256 amount) external;
}
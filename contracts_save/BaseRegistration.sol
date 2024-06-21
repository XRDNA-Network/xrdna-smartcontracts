// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms, RegistrationRenewalStorage, LibRegistration} from './libraries/LibRegistration.sol';
import {ISupportsRegistration} from './ISupportsRegistration.sol';

interface IActivatable {
    function activate() external;
    function deactivate() external;
}

abstract contract BaseRegistration is ISupportsRegistration {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    using LibRegistration for RegistrationRenewalStorage;

    modifier onlyRegistrationAdmin {
        require(isAdmin(msg.sender), "BaseRegistration: caller is not admin");
        _;
    }

    receive() external payable {}

    function isAdmin(address a) internal virtual view returns (bool);
    function owner() public virtual view returns (address);

    /**
     * @dev Sets the registration terms for the contract. This can only be called by the admin.
     */
    function setTerms(bytes32 termsType, RegistrationTerms memory terms) external onlyRegistrationAdmin {
        LibRegistration.load().setTerms(termsType, terms);
    }

    /**
     * @dev Returns the current registration terms for the contract. Any registered 
     * entity prior to this call is grandfathered into previous terms until renewal, if
     * applicable. If no terms were set when registered, the entity will never have to renew
     * and will always be considered registered.
     */
    function getTerms(bytes32 termsType) external view returns (RegistrationTerms memory) {
        return LibRegistration.load().getTerms(termsType);
    }

    /**
     * @dev Returns the registration terms for the given address.
     */
    function getEntityTerms(address addr) external view returns (RegistrationTerms memory) {
        return LibRegistration.load().getEntityTerms(addr);
    }

    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) external view returns (uint256) {
        return LibRegistration.load().getLastRenewal(addr);
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256) {
       return LibRegistration.load().getExpiration(addr);
    }

    /**
     * @dev Check whether an address is registered.
     */
    function isRegistered(address addr) external view returns (bool) {
        return LibRegistration.load().isRegistered(addr);
    }

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) external view returns (bool) {
        return LibRegistration.load().getExpiration(addr) < block.timestamp;
    }

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) external view returns (bool) {
        return LibRegistration.load().isInGracePeriod(addr);
    }

    /**
     * @dev Pays for the renewal of the given address. Anyone can call this function.
     */
    function renewFor(bytes32 tType, address addr) internal {
        RegistrationRenewalStorage storage e = LibRegistration.load();
        //if the entity is not registered, revert
        //this includes entities that were registered prior to terms being set
        require(e.isRegistered(addr), "BaseRegistration: not registered");
        require(msg.value >= e.terms[tType].fee, "BaseRegistration: insufficient funds");

        LibRegistration.load().renewRegistration(tType, addr);
    }

    /**
     * @dev Withdraws any funds in the contract. This can only be called by the admin.
     */
    function withdraw(uint256 amount) external onlyRegistrationAdmin {
        require(address(this).balance >= amount, "BaseRegistration: insufficient funds");
        payable(owner()).transfer(amount);
    }

    /**
     * @dev Creates a new registration for the given address. Called by the inheriting contract.
     */
    function createRegistration(bytes32 tType, address entity) internal {
        LibRegistration.load().createRegistration(tType, entity);
    }

    /** 
     * @dev Removes the registration for the given address
     */
    function removeRegistration(address addr) internal {
        LibRegistration.load().removeRegistration(addr);
    }

     /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) external view returns (bool) {
        return LibRegistration.load().canBeDeactivated(addr);
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) external view returns (bool) {
        return LibRegistration.load().canBeRemoved(addr);
    }

    /**
     * @dev Forces deactivation of an entity. Can be called by anyone but will only
        * succeed if the entity is inside the grace period
     */
    function forceDeactivation(address addr) external {
        RegistrationRenewalStorage storage rs = LibRegistration.load();
        require(rs.canBeDeactivated(addr), "BaseRegistration: cannot deactivate");
        IActivatable(addr).deactivate();
        emit AddressDeactivated(addr);
    }

    /**
     * @dev Forces removal of an entity. Can be called by anyone but will only
        * succeed if it is outside the grace period
     */
    function forceRemoval(address world) external {
        RegistrationRenewalStorage storage rs = LibRegistration.load();
        require(rs.canBeRemoved(world), "BaseRegistration: cannot remove");
        IActivatable(world).deactivate();
        emit AddressRemoved(world);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibAccess} from '../../core-libs/LibAccess.sol';
import {LibRoles} from '../../core-libs/LibRoles.sol';
import {LibRegistry, RegistrationRequest} from '../../core-libs/LibRegistry.sol';
import {IRegistry, CreateEntityArgs} from './IRegistry.sol';
import {LibRegistration, TermsSignatureVerification} from '../../entity-libs/registration/LibRegistration.sol';
import {LibEntityRemoval} from '../../entity-libs/removal/LibEntityRemoval.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {IRemovableEntity} from '../../entity-libs/interfaces/IRemovableEntity.sol';
import {ChangeEntityTermsArgs} from '../../entity-libs/interfaces/IRegistration.sol';

abstract contract BaseRegistry is IRegistry {

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "BaseCoreApp: caller is not an admin");
        _;
    }

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "BaseCoreApp: caller is not the owner");
        _;
    }

    modifier onlySigner {
        require(LibAccess.hasRole(LibRoles.ROLE_SIGNER, msg.sender), "BaseCoreApp: caller is not a signer");
        _;
    }

    modifier onlyRegistered {
        require(isRegistered(msg.sender), "BaseRegistry: caller is not a registered entity");
        _;
    }

    receive() external payable {}

    function setProxyImplementation(address newImpl) external onlyAdmin {
        require(newImpl != address(0), "BaseRegistry: implementation cannot be zero address");
        LibRegistry.load().proxyImplementation = newImpl;
        emit ProxyImplementationSet(newImpl);
    }

    function proxyImplementation() external view returns (address) {
        return LibRegistry.load().proxyImplementation;
    }

    function setEntityImplementation(address newImpl) external onlyAdmin {
        require(newImpl != address(0), "BaseRegistry: implementation cannot be zero address");
        LibRegistry.setEntityImplementation(newImpl);
    }

    function entityImplementation() external view returns (address) {
        return LibRegistry.load().entityImplementation;
    }

    function owner() external view override returns (address) {
        return LibAccess.owner();
    }

    function addSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.addSigners(signers);
    }

    function removeSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.removeSigners(signers);
    }

    function isSigner(address a) external view returns (bool) {
        return LibAccess.isSigner(a);
    }

    function setOwner(address o) external onlyOwner {
        LibAccess.setOwner(o);
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return LibAccess.hasRole(role, account);
    }

    function grantRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.revokeRole(role, account);
    }

    function isRegistered(address addr) public view returns (bool)  {
        return LibRegistration.isRegistered(addr);
    }

    function getEntityByName(string calldata nm) external view returns (address) {
        return LibRegistration.getEntityByName(nm);
    }

    function getEntityTerms(address addr) external view returns (RegistrationTerms memory) {
        return LibEntityRemoval.getEntityTerms(addr);
    }


    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external onlySigner {
        LibRegistration.changeEntityTerms(args);
    }

    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) external view returns (bool) {
        return LibEntityRemoval.canBeDeactivated(addr);
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) external view returns (bool) {
        return LibEntityRemoval.canBeRemoved(addr);
    }

    /**
     * @dev Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    function enforceDeactivation(IRemovableEntity addr) external {
        LibEntityRemoval.enforceDeactivation(addr);
    }

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) external {
        LibEntityRemoval.enforceRemoval(e);
    }


    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) external view returns (uint256) {
        return LibEntityRemoval.getLastRenewal(addr);
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256) {
        return LibEntityRemoval.getExpiration(addr);
    }

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) external view returns (bool) {
        return LibEntityRemoval.isExpired(addr);
    }

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) external view returns (bool) {
        return LibEntityRemoval.isInGracePeriod(addr);
    }

    /**
     * @dev Renew an entity by paying the renewal fee.
     */
    function renewEntity(address addr) external payable {
        LibEntityRemoval.renewEntity(addr);
    }

    function upgradeEntity(bytes calldata data) external onlyRegistered {
        LibRegistry.upgradeEntity(data);
    }

    function _verifyNewEntityTermsSignature(CreateEntityArgs calldata args) internal view {
        LibRegistration.verifyNewEntityTermsSignature(TermsSignatureVerification({
            owner: args.owner,
            terms: args.terms,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        }));
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ISupportsRegistration} from '../ISupportsRegistration.sol';
import {RegistrationTerms} from '../libraries/LibRegistration.sol';

/**
 * @dev Arguments for creating a new registrar
 */
struct CreateRegistrarArgs {

    //whether to send any registration attached tokens to the registrar owner
    //or registrar contract itself
    bool sendTokensToOwner;

    //globally unique name of the registrar
    string name;

    //the owner to assign to the registrar contract and transfer
    //any initial tokens to if required
    address payable owner;

    //the registration terms for the registrar
    RegistrationTerms worldRegistrationTerms;
}

/**
 * @dev When a world chooses to migrate to a new registrar, they do so through a new 
 * registrar off-chain. But they must have approval of their existing registrar. The 
 * exception is if the current registrar is inactive, in which case the world can migrate
 * without approval. The signature signs the world address, the new registrar address, and 
 * an expiration time. The world must also approve the migration by signing the same data.
 */
struct WorldMigrationArgs {
    //new registrar
    address world;

    //the signature is valid until this timestamp
    uint256 expiration;

    //signature of the current registrar agreeing to move. 
    bytes currentRegistrarSignature;

    //signature of a world signer agreeing to the migration
    bytes worldSignature;
}

/**
 * @title IRegistrarRegistry
 * @dev Interface for the registrar registry contract. The registrar registry holds registrar
 * IDs and their list of authorized signers. Registrars are the only entity allowed to regsiter
 * worlds in the world registry. They must go through XRDNA to be approved as a registrar.
 */
interface IRegistrarRegistry is ISupportsRegistration {

    event RegistryAddedRegistrar(address indexed registrarContract, address indexed owner, uint256 tokens);
    event RegistryDeactivatedRegistrar(address indexed registrarContract);
    event RegistryReactivatedRegistrar(address indexed registrarContract);
    event RegistryRemovedRegistrar(address indexed registrarContract);
    event RegistryUpgradedRegistrar(address indexed registrarContract, address newVersion);

    /**
     * @dev Returns the registrar contract address by the name of the registrar.
     */
    function getRegistrarByName(string memory name) external view returns (address);

    /**
     * @dev Returns true if the address is a registered registrar contract
     */
    function isRegistrar(address registrar) external view returns (bool);

    /**
     * @dev Registers a new registrar with the given initial signer. This can only be called by admin
     */
    function register(CreateRegistrarArgs calldata args) external payable;

    /**
     * @dev Deactivates a registrar. This can only be called by admin.
     */
    function deactivateRegistrar(address registrar) external;

    /**
     * @dev Reactivates a registrar. This can only be called by admin.
     */
    function reactivateRegistrar(address registrar) external;

    /**
     * @dev Removes a registrar from the registry. This can only be called by admin.
     */
    function removeRegistrar(address registrar) external;

    /**
     * @dev Renews the registration for the registrar. Anyone can call this and pay 
     * the appropriate fee.
     */
    function renewRegistrarRegistration(address registrar) external payable;

    /**
     * @dev Returns the current version of the registrar registry contract
     */
    function currentRegistrarVersion() external view returns (uint256);

    /**
     * @dev Migrates a registrar to a new registrar. This can only be called by the new registrar
     */
    function migrateRegistrar(WorldMigrationArgs calldata args) external;

    /**
     * @dev Upgrades the registrar contract to a new version. This can only be called by the registrar
     */
    function upgradeRegistrar(bytes calldata initData) external;
}
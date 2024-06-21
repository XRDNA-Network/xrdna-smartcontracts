// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBaseAccess} from '../IBaseAccess.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {RegistrationTerms} from '../libraries/LibRegistration.sol';
import {ISupportsRegistration} from '../ISupportsRegistration.sol';
import {WorldMigrationArgs} from './IRegistrarRegistry.sol';
import {CreateRegistrarArgs} from './IRegistrarRegistry.sol';

struct WorldRegistrationArgs {

    //whether any attached tokens for registration are sent to the world owner address or
    //to the world contract itself
    bool sendTokensToWorldOwner;

    //owner of the world contract
    address owner;

    //world's spatial vector address assigned by registrar
    VectorAddress baseVector;

    //world's globally unique name
    string name;

    //any additional init data for the world.
    bytes initData;

    //signature of the vector address authority that issued the vector address to the registrar
    bytes vectorAuthoritySignature;

    //company registration terms
    RegistrationTerms companyTerms;

    //avatar registration terms
    RegistrationTerms avatarTerms;
}

/**
    * @dev Interface for registrar. The registrar is responsible for registering world 
    * contracts. Registration can have terms attached where worlds must renew their 
    * registration within a certain time period before becoming inactive. After a grace
    * period, the world can be removed from the registrar and its name and vector address
    * made available for reuse. Worlds are not required to approve migration
*/ 
interface IRegistrar is IBaseAccess, ISupportsRegistration {

    event WorldRegistered(address indexed world, address indexed owner, VectorAddress vectorAddress);
    event RegistryDeactivatedWorld(address indexed world, address indexed registrar);
    event RegistryReactivatedWorld(address indexed world, address indexed registrar);
    event RegistryRemovedWorld(address indexed world, address indexed registrar);
    event RegistrarDeactivated();
    event RegistrarReactivated();
    event RegistrarUpgraded(address indexed newVersion);

    /**
        * @dev Returns the version of the registrar contract. Can be compared with factory 
        * to determine if an upgrade is needed
     */
    function version() external view returns (uint256);

    /**
     * @dev Initializes the registrar contract. Must be called by the factory
     */
    function init(CreateRegistrarArgs calldata args) external;

    /**
     * @dev Returns the name of the registrar
     */
    function name() external view returns (string memory);

    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(WorldRegistrationArgs memory args) external payable returns (address world);

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world) external;

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external;

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world) external;

    /**
     * @dev Migrate a world to a new registrar. This is called by the receiving registrar
     */
    function migrateWorld(WorldMigrationArgs calldata args) external;

    /**
     * @dev Renews the registration of a world. Can be called by anyone willing to 
     * pay the renewal fee
     */
    function renewWorldRegistration(address world) external payable;

    /**
     * @dev Deactivate the registrar. This will prevent any new registrations from being made
     * and will deactivate all existing worlds. Can only be called by the RegistrarRegistry
     */
    function deactivate() external;

    /**
     * @dev Reactivate the registrar. Can only be called by the RegistrarRegistry
     */
    function reactivate() external;

    /**
     * @dev Determines if the registrar is active
     */
    function isActive() external view returns (bool);

    /**
        * @dev Upgrades the registrar to a new version. Must be called by admin
     */
    function upgrade(bytes calldata initData) external;

    /**
     * @dev Complete upgrade and set implementation to the next version. This is called
     * by the factory after new proxy is deployed
     */
    function upgradeComplete(address nextVersion) external;
}
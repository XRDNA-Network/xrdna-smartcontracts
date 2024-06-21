// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {ISupportsRegistration} from '../ISupportsRegistration.sol';
import {RegistrationTerms} from '../libraries/LibRegistration.sol';

/**
 * Request to register a new world
 */
struct WorldRegistrationRequest {

    //registrar contract creating world
    address registrar;

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
 * @dev Interface for world registry. The world registry is responsible for registering and
 * upgrading world contracts. Only registrars can register worlds. Registrars are registered
 * in the RegistrarRegistry.
 */
interface IWorldRegistry {

    event WorldRegistered(address indexed world, address indexed owner, VectorAddress vectorAddress);
    event RegistryDeactivatedWorld(address indexed world, address indexed registrar);
    event RegistryReactivatedWorld(address indexed world, address indexed registrar);
    event RegistryRemovedWorld(address indexed world, address indexed registrar);
    event RegistryChangedWorldRegistrar(address indexed world, address indexed oldRegistrar, address indexed newRegistrar);
    event VectorAddressAuthorityAdded(address indexed authority);
    event VectorAddressAuthorityRemoved(address indexed authority);

    /**
     * @dev Returns the world contract address by name.
     */
    function getWorldByName(string memory name) external view returns (address);

    /**
     * @dev Determines if the world contract is registered in the registry.
     */
    function isWorld(address world) external view returns (bool);

    /**
     * @dev Determines if the given address is a vector address issuing authority.
     */
    function isVectorAddressAuthority(address auth) external view returns(bool);

    /**
     * @dev Sets the world factory address. Must be called by admin.
     */
    function setWorldFactory(address factory) external;

    /**
     * @dev Adds a vector address issuing authority. Must be called by admin.
     */
    function addVectorAddressAuthority(address auth) external;

    /**
     * @dev Removes a vector address issuing authority. Must be called by admin.
     */
    function removeVectorAddressAuthority(address auth) external;

    /**
     * @dev Registers a new world and generates a new world contract instance. 
     * Must be called by a registered registrar.
     */
    function register(WorldRegistrationRequest memory request) external payable returns (address);

    /**
     * @dev Deactivates the world contract. Must be called by a valid registrar. This 
     * only flags the world as inactive. It does not remove its entry in the registry.
     * But all checks for world existence will show that it does not exist. However, its
     * name is preserved until it is removed.
     */
    function deactivateWorld(address world) external;

    /**
     * @dev Reactivates the world contract. Must be called by a valid registrar.
     */
    function reactivateWorld(address world) external;

    /**
     * @dev Removes the world contract from the registry. Must be called by a valid registrar
     * This ultimately makes the world's name available for reuse.
     */
    function removeWorld(address world) external;

    /**
     * @dev Upgrades the world contract to a new version. Must be called by the world contract.
     */
    function upgradeWorld(bytes calldata initData) external;

    /**
     * @dev Returns the current version of the world contract. This should align with 
     * factory's supported version.
     */
    function currentWorldVersion() external view returns (uint256);
}
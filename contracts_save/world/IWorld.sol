// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {IWorldHook} from './IWorldHook.sol';
import {IBaseAccess} from '../IBaseAccess.sol';
import {RegisterExperienceRequest} from '../experience/IExperienceRegistry.sol';
import {WorldRegistrationRequest} from './IWorldRegistry.sol';
import {ISupportsHook} from '../ISupportsHook.sol';
import {ISupportsRegistration} from '../ISupportsRegistration.sol';

/**
 * Request to register a new company
 */
struct CompanyRegistrationArgs {
    //whether to send any attached tokens to the company owner
    //or to the company contract itself
    bool sendTokensToCompanyOwner;

    //company owner
    address owner;

    //company's globally unique name
    string name;

    //any additional init data for the company.
    bytes initData;
}

struct AvatarRegistrationArgs {


    bool sendTokensToAvatarOwner;

    //the addres sof the avatar owner
    address avatarOwner;

    //the address of the default experience contract where the new avatar will start
    address defaultExperience;

    //the username of the new avatar, must be globally unique, case-insensitive
    string username;

    //initialization data to pass to the avatar contract
    bytes initData;
}

/**
 * @dev Interface for world contract. The world contract is responsible for registering and
 * upgrading companies and avatars and applying hooks to enforce additional rules.
 */
interface IWorld is IBaseAccess, ISupportsRegistration {

    event WorldRegisteredCompany(address indexed company, VectorAddress vector, string name);
    event WorldDeactivatedCompany(address indexed company);
    event WorldReactivatedCompany(address indexed company);
    event WorldRegisteredAvatar(address indexed avatar, address indexed experience);
    event WorldUpgraded(address indexed oldWorld, address indexed newWorld);
    event WorldHookSet(address indexed hook);
    event WorldHookRemoved();
    event WorldAddedExperience(address indexed experience, address indexed company, uint256 indexed portalId);
    event WorldDeactivated();
    event WorldReactivated();
    event WorldRegistrarChanged(address indexed newRegistrar);

    /**
     * @dev Returns the base vector address of the world assigned by a registrar.
     */
    function getBaseVector() external view returns (VectorAddress memory);

    /**
     * @dev Returns the name of the world.
     */
    function getName() external view returns (string memory);

    /**
     * @dev Returns the version of the world contract.
     */
    function version() external view returns (uint256);

    /**
     * @dev Returns the registrar that registered the world.
     */
    function registrar() external view returns (address);

    /**
     * @dev Deactivates the world contract. This can only be called by the world registry
     */
    function deactivate() external;

    /**
     * @dev Reactivates the world contract. This can only be called by the world registry.
     */
    function reactivate() external;
    
    /**
     * @dev Determines if the world contract is active.
     */
    function isActive() external view returns (bool);

    /**
     * @dev Registers a company to oeprate within the world. This can only 
     * be called by a world signer.
     */
    function registerCompany(CompanyRegistrationArgs memory args) external payable returns (address company);
    
    /**
     * @dev Deactivates a company from company registry. This can only be called by a world signer.
     */
    function deactivateCompany(address company) external;

    /**
     * @dev Reactivates a company. This can only be called by a world signer.
     */
    function reactivateCompany(address company) external;

    /**
     * @dev Removes a company from the world. This can only be called by a world signer.
     */
    function removeCompany(address company) external;

    /**
     * @dev Registers an avatar to operate within the world. This can only be called by 
     * a world signer.
     */
    function registerAvatar(AvatarRegistrationArgs memory args) external payable returns (address avatar);
    
    /**
     * @dev Registers an experience to operate within the world. This can only be called by 
     * a registered company whose "world" is set to this world contract.
     */
    function registerExperience(RegisterExperienceRequest memory req) external returns (address experience, uint256 portalId);
    
    /**
     * @dev Deactivates an experience. This can only be called by the owning company
     */
    function deactivateExperience(address experience) external returns (uint256 portalId);

    /**
     * @dev Upgrades the world contract to a new version. Must be called by the world admin.
     */
    function upgrade(bytes calldata initData) external;

    /**
     * @dev Initialize world instance. Called by factory when creating new world.
     */
    function init(WorldRegistrationRequest memory request) external;

    /**
     * @dev Called by the world factory when the upgrade is complete and to assign the 
     * new impl address to its proxy.
     */
    function upgradeComplete(address nextVersion) external;

    /**
     * @dev Uses world contract or supplied funds to renew registration
     */
    function renewRegistration() external payable;

    /**
     * @dev Sets a new registrar for the world. This can only be called by the world registry
     */
    function registrarChanged(address newRegistrar) external;


    /**
     * @dev Renew the registration for an avatar by paying any necessary registration fees.
     */
    function renewAvatarRegistration(address avatar) external payable;

    /**
     * @dev Renew the registration for a company by paying any necessary registration fees.
     */
    function renewCompanyRegistration(address company) external payable;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AvatarRegistrationRequest} from '../../avatar/IAvatarRegistry.sol';
import {WorldCreateRequest} from './IWorldFactoryV2.sol';
import {VectorAddress} from '../../VectorAddress.sol';
import {IWorldHook} from './IWorldHook.sol';
import {IBaseAccess} from '../../IBaseAccess.sol';
import {RegisterExperienceRequest} from '../../experience/IExperienceRegistry.sol';

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

/**
 * @dev Interface for world contract. The world contract is responsible for registering and
 * upgrading companies and avatars and applying hooks to enforce additional rules.
 */
interface IWorldV2 is IBaseAccess {

    event WorldRegisteredCompany(address indexed company, VectorAddress vector, string name);
    event WorldDeactivatedCompany(address indexed company);
    event WorldReactivatedCompany(address indexed company);
    event WorldRegisteredAvatar(address indexed avatar, address indexed experience);
    event WorldUpgraded(address indexed oldWorld, address indexed newWorld);
    event WorldHookSet(address indexed hook);
    event WorldHookRemoved();
    event WorldAddedExperience(address indexed experience, address indexed company, uint256 indexed portalId);

    /**
     * @dev Returns the owner of the world contract.
     */
    function getOwner() external view returns (address);

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
     * @dev Registers a company to oeprate within the world. This can only 
     * be called by a world signer.
     */
    function registerCompany(CompanyRegistrationArgs memory args) external payable returns (address company);
    
    /**
     * @dev Deactivates a company from company registry. This can only be called by a world admin.
     */
    function deactivateCompany(address company) external;

    /**
     * @dev Reactivates a company. This can only be called by a world admin.
     */
    function reactivateCompany(address company) external;

    /**
     * @dev Registers an avatar to operate within the world. This can only be called by 
     * a world signer.
     */
    function registerAvatar(AvatarRegistrationRequest memory args) external payable returns (address avatar);
    
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
    function init(WorldCreateRequest memory request) external;

    /**
     * @dev Called by the world factory when the upgrade is complete and to assign the 
     * new impl address to its proxy.
     */
    function upgradeComplete(address nextVersion) external;

    /**
     * @dev Sets the world hook. Must be called by the world admin.
     */
    function setHook(IWorldHook hook) external;

    /**
     * @dev Removes the world hook. Must be called by the world admin.
     */
    function removeHook() external;

    /**
     * @dev Returns the world hook.
     */
    function hook() external view returns (IWorldHook);

    /**
     * @dev Withdraws funds from the world contract. Must be called by the world admin.
     */
    function withdraw(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {AvatarRegistrationArgs, CompanyRegistrationArgs} from './IWorld.sol';
import {RegisterExperienceRequest} from '../experience/IExperienceRegistry.sol';

/**
 * @dev Interface for world hooks. Hooks allow additional rules to be attached to a world, 
 * which must be satisfied before a company or avatar can be registered.
 */
interface IWorldHook {

    ////////////////////////////////////////////////////////////////////////////
    // Company Related hooks
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Returns whether the given company can be registered in the world.
     */
    function beforeRegisterCompany(CompanyRegistrationArgs memory args) external returns (bool);
    
    /**
     * @dev Called before deactivating a company. Returns whether the company can be deactivated.
     */
    function beforeDeactivateCompany(address company) external returns (bool);

    /**
        * @dev Called before reactivating a company. Returns whether the company can be reactivated.
     */
    function beforeReactivateCompany(address company) external returns (bool);

    /**
     * @dev Called before removing a company. Returns whether the company can be removed.
     */
    function beforeRemoveCompany(address company) external returns (bool);

    /**
     * @dev Called before renewing a company's registration. Returns whether the company can be renewed.
     */
    function beforeRenewCompanyRegistration(address company) external returns (bool);

    
    ////////////////////////////////////////////////////////////////////////////
    // Avatar Related hooks
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Returns whether the given avatar can be registered in the world.
     */
    function beforeRegisterAvatar(AvatarRegistrationArgs memory args) external returns (bool);

    /**
     * @dev Called before deactivating an avatar. Returns whether the avatar can be deactivated.
     */
    function beforeDeactivateAvatar(address avatar) external returns (bool);

    /**
     * @dev Called before reactivating an avatar. Returns whether the avatar can be reactivated.
     */
    function beforeReactivateAvatar(address avatar) external returns (bool);

    /**
     * @dev Called before removing an avatar. Returns whether the avatar can be removed.
     */
    function beforeRemoveAvatar(address avatar) external returns (bool);

    /**
     * @dev Called before renewing an avatar's registration. Returns whether the avatar can be renewed.
     */
    function beforeRenewAvatarRegistration(address avatar) external returns (bool);


    ////////////////////////////////////////////////////////////////////////////
    // Experience Related hooks
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Called before registering an experience. Returns whether the experience can be registered.
     */
    function beforeRegisterExperience(RegisterExperienceRequest calldata req) external returns (bool);

    /**
     * @dev Called before deactivating an experience. Returns whether the experience can be deactivated.
     */
    function beforeDeactivateExperience(address experience) external returns (bool);
    

    ////////////////////////////////////////////////////////////////////////////
    // World Related hooks
    ////////////////////////////////////////////////////////////////////////////
    /**
     * @dev Called before renewing world registration. Returns whether the world can be renewed.
     */
    function beforeRenewRegistration() external returns (bool);

    /**
     * @dev Called when the registrar for the world has changed. Returns whether the registrar can be changed.
     */
    function beforeRegistrarChanged(address oldRegistrar, address newRegistrar) external returns (bool);

    /**
     * @dev Called before upgrading the world. Returns whether the world can be upgraded.
     */
    function beforeUpgrade(bytes calldata initData) external returns (bool);
}
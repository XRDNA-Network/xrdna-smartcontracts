// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {CompanyRegistrationArgs} from './IWorldV2.sol';
import {AvatarRegistrationRequest} from '../../avatar/IAvatarRegistry.sol';

/**
 * @dev Interface for world hooks. Hooks allow additional rules to be attached to a world, 
 * which must be satisfied before a company or avatar can be registered.
 */
interface IWorldHook {

    /**
     * @dev Returns whether the given company can be registered in the world.
     */
    function beforeRegisterCompany(CompanyRegistrationArgs memory args) external returns (bool);
    
    /**
     * @dev Returns whether the given avatar can be registered in the world.
     */
    function beforeRegisterAvatar(AvatarRegistrationRequest memory req) external returns (bool);
}
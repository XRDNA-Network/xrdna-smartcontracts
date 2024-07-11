// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibRegistration.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

struct CreateExperienceArgs {
    address company;
    string name;
    VectorAddress vector;
    bytes initData;
}


/**
 * @title IExperienceRegistry
 * @dev The IExperienceRegistry contract is a registry for experiences. It is used to create, deactivate, and remove experiences.
 * All experience creations are initiated by a company contract but go through the company's parent
 * world contract. This is mostly to minimize off-chain logistics of monitoring experience state for 
 * both companies and worlds.
 */
interface IExperienceRegistry is IRemovableRegistry, IVectoredRegistry {

    /**
     * @dev Creates a new experience.
     */
    function createExperience(CreateExperienceArgs calldata args) external payable returns (address, uint256);

    /**
     * @dev Deactivates an experience. This can only be called by a world. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function deactivateExperience(address company, address exp, string calldata reason) external;

    /**
     * @dev Reactivates an experience. This can only be called by a world. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function reactivateExperience(address company, address exp) external;

    /**
     * @dev Removes an experience from the registry. This can only be called by a world. The company must be
        * the owner of the experience. Company initiates this call through a world so that events are
        * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function removeExperience(address company, address exp, string calldata reason) external returns (uint256 portalId);

    
}
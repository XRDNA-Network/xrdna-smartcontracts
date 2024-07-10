// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

struct CreateExperienceArgs {
    address company;
    string name;
    VectorAddress vector;
    bytes initData;
}

struct ExperienceInfo {
    address company;
    address world;
    uint256 portalId;
}

interface IExperienceRegistry is IRemovableRegistry, IVectoredRegistry {

    function createExperience(CreateExperienceArgs calldata args) external payable returns (address, uint256);

    /**
     * @dev Deactivates an experience. This can only be called by the world registry. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function deactivateExperience(address company, address exp, string calldata reason) external;

    /**
     * @dev Reactivates an experience. This can only be called by the world registry. The company must be 
     * the owner of the experience. Company initiates this call through a world so that events are 
     * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function reactivateExperience(address company, address exp) external;

    /**
     * @dev Removes an experience from the registry. This can only be called by the world. The company must be
        * the owner of the experience. Company initiates this call through a world so that events are
        * emitted for both the company and world for tracking purposes. The company must also belong to the world.
     */
    function removeExperience(address company, address exp, string calldata reason) external returns (uint256 portalId);

    /**
     * @dev Returns the experience info for the given experience address.
     */
    function getExperienceInfo(address exp) external view returns (ExperienceInfo memory);
}
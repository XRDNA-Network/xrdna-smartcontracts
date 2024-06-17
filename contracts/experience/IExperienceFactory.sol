// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {IBaseFactory} from '../IBaseFactory.sol';

/**
 * @dev Interface for a factory that creates experiences.
 */
interface IExperienceFactory is IBaseFactory {

    /**
     * @dev Upgrades an experience to a new version. This can only be called by the registry
     * to initiate the upgrade.
     */
    function upgradeExperience(address experience, bytes calldata data) external returns (address);

    /**
     * @dev Creates a new experience with the given parameters. This can only be called by the registry.
     */
    function createExperience(address company, string memory _name, VectorAddress memory vector, bytes memory data) external returns (address);
}
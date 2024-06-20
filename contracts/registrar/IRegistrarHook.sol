// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {WorldRegistrationArgs} from './IRegistrar.sol';
import {WorldMigrationArgs} from './IRegistrarRegistry.sol';

interface IRegistrarHook {

    /**
     * @dev Called before registering a new world.
     */
    function beforeRegisterWorld(WorldRegistrationArgs memory args) external returns (bool);

    /**
     * @dev Called before deactivating a world.
     */
    function beforeDeactivateWorld(address world) external returns (bool);

    /**
     * @dev Called before reactivating a world.
     */
    function beforeReactivateWorld(address world) external returns (bool);

    /**
     * @dev Called before removing a world.
     */
    function beforeRemoveWorld(address world) external returns (bool);

    /**
     * @dev Called before migrating a world to a new registrar
     */
    function beforeMigrateWorld(WorldMigrationArgs memory args) external returns (bool);

    /**
     * @dev Called before renewing a world's registration.
     */
    function beforeRenewWorldRegistration(address world) external returns (bool);

    /**
     * @dev Called before upgrading the registrar.
     */
    function beforeUpgrade(bytes calldata initData) external returns (bool);
}
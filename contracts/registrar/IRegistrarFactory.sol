// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBaseFactory} from '../IBaseFactory.sol';
import {CreateRegistrarArgs} from './IRegistrarRegistry.sol';

interface IRegistrarFactory is IBaseFactory {
    
    /**
     * @dev Upgrades an existing registrar to the latest version. Called by the registry
     * to carry out the upgrade.
     */
    function upgradeRegistrar(address registry, bytes calldata initData) external returns (address);

    /**
     * @dev Creates a new registrar contract and initializes it with the given data. Called by the registry
     */
    function createRegistrar(CreateRegistrarArgs calldata args) external returns (address);
}
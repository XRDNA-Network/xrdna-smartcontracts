// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAccessControl} from '@openzeppelin/contracts/access/IAccessControl.sol';
import {IModuleRegistry} from './IModuleRegistry.sol';

interface IModuleRegistryWithAccess is IModuleRegistry, IAccessControl {

    function owner() external view returns (address);
    function isOwner(address account) external view returns (bool);
    
}
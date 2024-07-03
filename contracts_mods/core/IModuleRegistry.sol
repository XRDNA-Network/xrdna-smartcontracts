// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IModule, ModuleVersion} from '../modules/IModule.sol';

struct ModuleReference {
    bool enabled;
    address module;
    ModuleVersion version;
}

interface IModuleRegistry {

    event ModuleAdded(address indexed module, uint16 indexed major, uint16 indexed minor, string name);
    event ModuleUpgraded(address indexed module, uint16 indexed major, uint16 indexed minor, string name);
    event ModuleRolledBack(address indexed module, uint16 indexed major, uint16 indexed minor, string name);
    event ModuleDisabled(string name);
    event ModuleEnabled(string name);
    
    function get(string calldata name) external view returns (ModuleReference memory);
    function getVersion(string calldata name) external view returns (ModuleVersion memory);
    function put(IModule mod) external;
    function upgrade(IModule mod) external;
    function rollback(IModule mod) external;
    function disable(string calldata name) external;
    function enable(string calldata name) external;
}
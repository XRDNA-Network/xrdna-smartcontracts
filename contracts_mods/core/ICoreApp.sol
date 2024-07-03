// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ModuleVersion} from '../modules/IModule.sol';

interface ICoreApp {

    event ModuleUpgraded(address indexed module, uint16 indexed major, uint16 indexed minor, string name);
    event ModuleRolledBack(address indexed module, uint16 indexed major, uint16 indexed minor, string name);
    event AppRollback(uint16 indexed major, uint16 indexed minor);
    event AppUpgraded(uint16 indexed major, uint16 indexed minor);

    function version() external view returns (ModuleVersion memory);

    function owner() external view returns (address);
    function addSigners(address[] calldata signers) external;
    function removeSigners(address[] calldata signers) external;
    function isSigner(address a) external view returns (bool);
    function setOwner(address owner) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;

}
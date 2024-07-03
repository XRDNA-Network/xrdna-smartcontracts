// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ModuleVersion} from '../IModule.sol';

interface IRegisteredEntity {

    function name() external view returns (string memory);
    function version() external view returns (ModuleVersion memory);
    function init(address owner, string calldata name, bytes calldata initData) external;

    /**
     * @dev Upgrade the implementation of the entity. This is only callable by the entity owner. This 
     * initiates an upgrade request through the entity registry.
     */
    function upgrade(bytes calldata data) external;

    /**
     * @dev After being upgraded, all registered entities must be able to initialize any new 
     * data requirements as part of the upgrade.
     */
    function postUpgradeInit(bytes calldata data) external;

    function owner() external view returns (address);
    function addSigners(address[] calldata signers) external;
    function removeSigners(address[] calldata signers) external;
    function isSigner(address a) external view returns (bool);
    function setOwner(address owner) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
}
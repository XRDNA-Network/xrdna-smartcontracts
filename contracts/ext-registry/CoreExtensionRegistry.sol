// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreExtensionRegistry} from './ICoreExtensionRegistry.sol';
import {LibCoreExtensionRegistry} from './LibCoreExtensionRegistry.sol';
import {IExtension} from '../interfaces/IExtension.sol';
import {LibAccess} from '../libraries/LibAccess.sol';
import {LibRoles} from '../libraries/LibRoles.sol';
import {IAccessControl} from '../interfaces/IAccessControl.sol';

struct CoreExtensionRegistryConstructorArgs {
    address owner;
    address[] admins;
}   

contract CoreExtensionRegistry is IAccessControl, ICoreExtensionRegistry {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "CoreExtensionRegistry: caller is not an admin");
        _;
    }

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "CoreExtensionRegistry: caller is not the owner");
        _;
    }

    constructor(CoreExtensionRegistryConstructorArgs memory args) {
        LibAccess.initAccess(args.owner, args.admins);
    }

    function getExtension(string calldata name) external view returns (address) {
        return LibCoreExtensionRegistry.getExtension(name);
    }

    function isRegistered(address _extension) external view returns (bool) {
        return LibCoreExtensionRegistry.isRegistered(_extension);
    }

    function addExtension(IExtension _extension) external {
        LibCoreExtensionRegistry.registerExtension(_extension);
    }

    function addExtensions(IExtension[] calldata _extensions) external {
        LibCoreExtensionRegistry.registerExtensions(_extensions);
    }

    function upgradeExtension(IExtension _extension) external {
        LibCoreExtensionRegistry.upgradeExtension(_extension);
    }

    function upgradeExtensions(IExtension[] calldata _extensions) external {
        LibCoreExtensionRegistry.upgradeExtensions(_extensions);
    }

    function removeExtension(address _extension) external {
        LibCoreExtensionRegistry.unregisterExtension(_extension);
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return LibAccess.hasRole(role, account);
    }

    function grantRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.revokeRole(role, account);
    }

    function addSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.addSigners(signers);
    }

    function removeSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.removeSigners(signers);
    }

    function isSigner(address account) external view returns (bool) {
        return LibAccess.isSigner(account);
    }

    function isAdmin(address account) external view returns (bool) {
        return LibAccess.isAdmin(account);
    }

    function owner() external view returns (address) {
        return LibAccess.owner();
    }

    function changeOwner(address newOwner) external onlyOwner {
        LibAccess.setOwner(newOwner);
    }
}
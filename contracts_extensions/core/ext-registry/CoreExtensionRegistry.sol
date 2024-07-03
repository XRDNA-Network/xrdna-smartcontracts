// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreExtensionRegistry} from '../interfaces/ICoreExtensionRegistry.sol';
import {LibCoreExtensionRegistry} from './LibCoreExtensionRegistry.sol';
import {IExtension} from '../extensions/IExtension.sol';
import {LibAccess} from '../LibAccess.sol';
import {LibRoles} from '../LibRoles.sol';

struct CoreExtensionRegistryConstructorArgs {
    address owner;
    address[] otherAdmins;
}   

contract CoreExtensionRegistry is ICoreExtensionRegistry {

    constructor(CoreExtensionRegistryConstructorArgs memory args) {
        LibAccess._setOwner(args.owner);

        for (uint256 i = 0; i < args.otherAdmins.length; i++) {
            LibAccess._grantRevokableRole(LibRoles.ROLE_ADMIN, args.otherAdmins[i]);
        }
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

}
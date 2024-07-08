// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BasicShell, InstallExtensionArgs} from '../../base-types/BasicShell.sol';
import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';

struct AvatarRegistryConstructorArgs {
    address owner;
    address extensionsRegistry;
    address worldRegistry;
    address[] admins;
}

contract AvatarRegistry is BasicShell {
    
    address public immutable worldRegistry;

    constructor(AvatarRegistryConstructorArgs memory args) BasicShell(ICoreExtensionRegistry(args.extensionsRegistry)) {
        
        require(args.worldRegistry != address(0), "AvatarRegistry: worldRegistry cannot be zero address");
        worldRegistry = args.worldRegistry;

        string[] memory extNames = new string[](3);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.FACTORY;
        extNames[2] = LibExtensionNames.AVATAR_REGISTRATION;
        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames,
            owner: args.owner,
            admins: args.admins
        });
        _installExtensions(extArgs);
    }

}

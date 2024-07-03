// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BasicShell, InstallExtensionArgs} from '../../base-types/BasicShell.sol';
import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';

struct ExperienceRegistryConstructorArgs {
    address owner;
    address extensionsRegistry;
    address worldRegistry;
    address[] admins;
}

contract ExperienceRegistry is BasicShell {
    
    address public immutable worldRegistry;

    constructor(ExperienceRegistryConstructorArgs memory args) BasicShell(ICoreExtensionRegistry(args.extensionsRegistry)) {
        
        require(args.worldRegistry != address(0), "ExperienceRegistry: worldRegistry cannot be zero address");
        worldRegistry = args.worldRegistry;

        string[] memory extNames = new string[](4);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.FACTORY;
        extNames[2] = LibExtensionNames.EXPERIENCE_REGISTRATION;
        extNames[3] = LibExtensionNames.EXPERIENCE_REMOVAL;
        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames,
            owner: args.owner,
            admins: args.admins
        });
        _installExtensions(extArgs);
    }

}

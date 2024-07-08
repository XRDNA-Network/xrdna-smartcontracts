// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BasicShell, InstallExtensionArgs} from '../../base-types/BasicShell.sol';
import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';

struct ERC721RegistryConstructorArgs {
    address owner;
    address extensionsRegistry;
    address[] admins;
}

contract ERC721Registry is BasicShell {
    
    constructor(ERC721RegistryConstructorArgs memory args) BasicShell(ICoreExtensionRegistry(args.extensionsRegistry)) {
        
        string[] memory extNames = new string[](4);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.FACTORY;
        extNames[2] = LibExtensionNames.ASSET_REGISTRATION;
        extNames[3] = LibExtensionNames.ASSET_REMOVAL;
        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames,
            owner: args.owner,
            admins: args.admins
        });
        _installExtensions(extArgs);
    }

}

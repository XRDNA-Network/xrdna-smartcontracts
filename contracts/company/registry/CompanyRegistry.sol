// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BasicShell, InstallExtensionArgs} from '../../base-types/BasicShell.sol';
import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';

struct CompanyRegistryConstructorArgs {
    address owner;
    address extensionsRegistry;
    address worldRegistry;
    address[] admins;
}

contract CompanyRegistry is BasicShell {
    
    address public immutable worldRegistry;

    constructor(CompanyRegistryConstructorArgs memory args) BasicShell(ICoreExtensionRegistry(args.extensionsRegistry)) {
        
        require(args.worldRegistry != address(0), "CompanyRegistry: worldRegistry cannot be zero address");
        worldRegistry = args.worldRegistry;

        string[] memory extNames = new string[](4);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.FACTORY;
        extNames[2] = LibExtensionNames.COMPANY_REGISTRATION;
        extNames[3] = LibExtensionNames.COMPANY_REMOVAL;
        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames,
            owner: args.owner,
            admins: args.admins
        });
        _installExtensions(extArgs);
    }

}

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BasicShell, InstallExtensionArgs} from '../../base-types/BasicShell.sol';
import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';

struct PortalRegistryConstructorArgs {
    address owner;
    address extensionsRegistry;
    address experienceRegistry;
    address avatarRegistry;
    address[] admins;
    
}

contract PortalRegistry is BasicShell {

    address public immutable experienceRegistry;
    address public immutable avatarRegistry;
    
    constructor(PortalRegistryConstructorArgs memory args) BasicShell(ICoreExtensionRegistry(args.extensionsRegistry)) {
        require(args.experienceRegistry != address(0), "PortalRegistry: Invalid experience registry");
        require(args.avatarRegistry != address(0), "PortalRegistry: Invalid avatar registry");
        experienceRegistry = args.experienceRegistry;
        avatarRegistry = args.avatarRegistry;

        
        string[] memory extNames = new string[](5);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.PORTAL_CONDITIONS;
        extNames[2] = LibExtensionNames.PORTAL_REMOVAL;
        extNames[3] = LibExtensionNames.PORTAL_REGISTRATION;
        extNames[4] = LibExtensionNames.PORTAL_JUMP;
        
        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames,
            owner: args.owner,
            admins: args.admins
        });
        _installExtensions(extArgs);
    }

}

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BasicShell, InstallExtensionArgs} from '../../base-types/BasicShell.sol';
import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';

struct WorldRegistryConstructorArgs {
    address owner;
    address vectorAuthority;
    address extensionsRegistry;
    address registrarRegistry;
    address[] admins;
}

contract WorldRegistry is BasicShell {
    
    address public immutable registrarRegistry;

    constructor(WorldRegistryConstructorArgs memory args) BasicShell(ICoreExtensionRegistry(args.extensionsRegistry)) {
        
        require(args.registrarRegistry != address(0), "WorldRegistry: registrarRegistry cannot be zero address");
        require(args.vectorAuthority != address(0), "WorldRegistry: vectorAuthority cannot be zero address");
        registrarRegistry = args.registrarRegistry;

        string[] memory extNames = new string[](5);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.FACTORY;
        extNames[2] = LibExtensionNames.WORLD_REGISTRATION;
        extNames[3] = LibExtensionNames.WORLD_REMOVAL;
        extNames[4] = LibExtensionNames.CHANGE_REGISTRAR;
        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames,
            owner: args.owner,
            admins: args.admins
        });
        _installExtensions(extArgs);
        LibAccess._grantRole(LibRoles.ROLE_VECTOR_AUTHORITY, args.vectorAuthority);
    }

    function isVectorAddressAuthority(address a) external view returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    function addVectorAddressAuthority(address a) external onlyAdmin {
        LibAccess._grantRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    function removeVectorAddressAuthority(address a) external onlyAdmin {
        LibAccess.revokeRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

}

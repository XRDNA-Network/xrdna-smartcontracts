// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BasicShell, InstallExtensionArgs} from '../../base-types/BasicShell.sol';
import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';

struct RegistrarRegistryConstructorArgs {
    address owner;
    address extensionsRegistry;
    address[] admins;
}

contract RegistrarRegistry is BasicShell, ITermsOwner {
    
    constructor(RegistrarRegistryConstructorArgs memory args) BasicShell(ICoreExtensionRegistry(args.extensionsRegistry)) {
        string[] memory extNames = new string[](4);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.FACTORY;
        extNames[2] = LibExtensionNames.REGISTRAR_REGISTRATION;
        extNames[3] = LibExtensionNames.REGISTRAR_ENTITY_REMOVAL;
        
        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames,
            owner: args.owner,
            admins: args.admins
        });
        _installExtensions(extArgs);
    }

    function isStillActive() external pure override returns (bool) {
        //registry is always active terms owner
        return true;
    }

    function isTermsOwnerSigner(address a) external view override returns (bool) {
        return LibAccess.isSigner(a);
    }

}

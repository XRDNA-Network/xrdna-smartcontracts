// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {BaseExtResolver, BaseExtResolverConstructorArgs, InstallExtensionArgs} from '../../base-types/BaseExtResolver.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';

contract RegistrarExtResolver is BaseExtResolver {

    constructor(BaseExtResolverConstructorArgs memory args) BaseExtResolver(args) {
         string[] memory extNames = new string[](4);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.REGISTRAR_WORLD_REGISTRATION;
        extNames[2] = LibExtensionNames.REMOVABLE_ENTITY;
        extNames[3] = LibExtensionNames.TERMS_OWNER;

        InstallExtensionArgs  memory extArgs = InstallExtensionArgs({
            names: extNames
        });
        _installExtensions(extArgs);
    }
}
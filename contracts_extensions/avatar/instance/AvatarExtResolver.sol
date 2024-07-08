// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {BaseExtResolver, BaseExtResolverConstructorArgs, InstallExtensionArgs} from '../../base-types/BaseExtResolver.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';

contract AvatarExtResolver is BaseExtResolver {

    constructor(BaseExtResolverConstructorArgs memory args) BaseExtResolver(args) {
        string[] memory extNames = new string[](4);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.AVATAR_INFO;
        extNames[2] = LibExtensionNames.AVATAR_WEARABLES;
        extNames[3] = LibExtensionNames.AVATAR_JUMP;
        
        

        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames
        });
        _installExtensions(extArgs);
    }
}
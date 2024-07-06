// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreExtensionRegistry} from '../../../ext-registry/ICoreExtensionRegistry.sol';
import {BaseExtResolver, BaseExtResolverConstructorArgs, InstallExtensionArgs} from '../../../base-types/BaseExtResolver.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';

contract NTERC20ExtResolver is BaseExtResolver {

    constructor(BaseExtResolverConstructorArgs memory args) BaseExtResolver(args) {
        string[] memory extNames = new string[](5);
        extNames[0] = LibExtensionNames.REMOVABLE_ENTITY;
        extNames[1] = LibExtensionNames.ASSET_CONDITION;
        extNames[2] = LibExtensionNames.ERC20_INFO;
        extNames[3] = LibExtensionNames.ERC20_MINTING;
        extNames[4] = LibExtensionNames.ERC20_TRANSFER;        

        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames
        });
        _installExtensions(extArgs);
    }
}
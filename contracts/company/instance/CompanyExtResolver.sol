// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreExtensionRegistry} from '../../ext-registry/ICoreExtensionRegistry.sol';
import {BaseExtResolver, BaseExtResolverConstructorArgs, InstallExtensionArgs} from '../../base-types/BaseExtResolver.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';

contract CompanyExtResolver is BaseExtResolver {

    constructor(BaseExtResolverConstructorArgs memory args) BaseExtResolver(args) {
        string[] memory extNames = new string[](6);
        extNames[0] = LibExtensionNames.ACCESS;
        extNames[1] = LibExtensionNames.REMOVABLE_ENTITY;
        extNames[2] = LibExtensionNames.TERMS_OWNER;
        extNames[3] = LibExtensionNames.COMPANY_ADD_EXPERIENCE;
        extNames[4] = LibExtensionNames.COMPANY_JUMP;
        extNames[5] = LibExtensionNames.COMPANY_MINTING;
        

        InstallExtensionArgs memory extArgs = InstallExtensionArgs({
            names: extNames
        });
        _installExtensions(extArgs);
    }
}
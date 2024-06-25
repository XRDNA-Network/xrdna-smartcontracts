// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CoreExtensionManager, CoreExtensionManagerConstructorArgs} from '../../core/ext-manager/CoreExtensionManager.sol';

contract RegistryExtMgr is CoreExtensionManager {
    constructor(CoreExtensionManagerConstructorArgs memory args) CoreExtensionManager(args) {
        string[] memory extNames = new string[](4);
        extNames[0] = 'xr.registration.RegistrationExt';
        extNames[1] = 'xr.core.EntityRemovalExt';
        extNames[2] = 'xr.entity.TermsOwnerExt';
        extNames[3] = 'xr.core.SignersExtension';
        _installExtensions(extNames);
    }
}
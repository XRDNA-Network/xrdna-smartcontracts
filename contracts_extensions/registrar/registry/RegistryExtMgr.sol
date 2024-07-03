// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtensionManager, BaseExtensionManagerConstructorArgs} from '../../core/ext-manager/BaseExtensionManager.sol';

contract RegistryExtMgr is BaseExtensionManager {
    constructor(BaseExtensionManagerConstructorArgs memory args) BaseExtensionManager(args) {
        string[] memory extNames = new string[](4);
        extNames[0] = 'xr.registration.RegistrationExt';
        extNames[1] = 'xr.registration.EntityRemovalExt';
        extNames[2] = 'xr.entity.TermsOwnerExt';
        extNames[3] = 'xr.core.SignersExt';
        _installExtensions(extNames);
    }
}
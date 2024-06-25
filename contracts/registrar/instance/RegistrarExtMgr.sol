// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CoreExtensionManager, CoreExtensionManagerConstructorArgs} from '../../core/ext-manager/CoreExtensionManager.sol';


contract RegistrarExtMgr is CoreExtensionManager {
    constructor(CoreExtensionManagerConstructorArgs memory args) CoreExtensionManager(args) {
        string[] memory extNames = new string[](5);
        extNames[0] = 'xr.entity.BasicEntityExt';
        extNames[1] = 'xr.core.FundsExt';
        extNames[2] = 'xr.core.SignersExtension';
        extNames[3] = 'xr.entity.RemovableExt';
        extNames[4] = 'xr.entity.TermsOwnerExt';
        _installExtensions(extNames);
    }
}
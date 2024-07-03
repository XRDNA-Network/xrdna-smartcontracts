// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CachedModule} from './LibModule.sol';
import {ModuleVersion} from '../modules/IModule.sol';
import {ICoreApp} from './ICoreApp.sol';

struct VersionControlStorage {
    uint16 major;
    uint16 minor;
}

/**
 * @title LibVersionControl
 * @dev The VersionControl library provides functions for managing version control of modules and the application.
 * Since it's involved in module installation, it cannot be upgraded without an entire app upgrade.
 */
library LibVersionControl {

    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.version.control.v1'))) - 1)) & bytes32(uint256(0xff));

    
    function load() internal pure returns (VersionControlStorage storage vcs) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            vcs.slot := slot
        }
    }

    function canUpgradeModule(CachedModule storage entry) external view returns (bool) {
        VersionControlStorage storage vcs = load();
        ModuleVersion memory v = entry.version;
        return v.major == vcs.major && v.minor > vcs.minor;
    }

    function upgradeModule(CachedModule storage entry, string memory name) external {
        VersionControlStorage storage vcs = load();
        uint16 major = entry.version.major;
        uint16 minor = entry.version.minor;
        require(major > vcs.major || (major == vcs.major && minor > vcs.minor), "VersionControl: upgrade version must be greater");
        vcs.major = major;
        vcs.minor = minor;
        emit ICoreApp.ModuleUpgraded(entry.module, entry.version.major, entry.version.minor, name);
    }

    function rollbackModule(CachedModule storage entry, string memory name) external {
        VersionControlStorage storage vcs = load();
        uint16 major = entry.version.major;
        uint16 minor = entry.version.minor;
        require(major < vcs.major || (major == vcs.major && minor < vcs.minor), "VersionControl: rollback version must be lower");
        vcs.major = major;
        vcs.minor = minor;
        emit ICoreApp.ModuleRolledBack(entry.module, vcs.major, vcs.minor, name);
    }

    function upgradedApp(uint16 major, uint16 minor) external {
        VersionControlStorage storage vcs = load();
        require(major > vcs.major || (major == vcs.major && minor > vcs.minor), "VersionControl: upgrade version must be greater");
        vcs.major = major;
        vcs.minor = minor;
        emit ICoreApp.AppUpgraded(major, minor);
    }

    function rollbackApp(uint16 major, uint16 minor) external {
        VersionControlStorage storage vcs = load();
        require(major < vcs.major || (major == vcs.major && minor < vcs.minor), "VersionControl: rollback version must be lower");
        vcs.major = major;
        vcs.minor = minor;
        emit ICoreApp.AppRollback(vcs.major, vcs.minor);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibAccess} from '../libraries/LibAccess.sol';
import {LibRoles} from '../libraries/LibRoles.sol';
import {IExtension, ExtensionMetadata} from '../interfaces/IExtension.sol';
import {LibStringCase} from '../libraries/LibStringCase.sol';
import {LibStorageSlots} from '../libraries/LibStorageSlots.sol';

struct ExtensionRegistryStorage {
    
    mapping(string => address) extensionsByName;
    mapping(address => ExtensionMetadata) extensions;
}

library LibCoreExtensionRegistry {
    using LibStringCase for string;

    //see EIP-7201
    
    function load() internal pure returns (ExtensionRegistryStorage storage ds) {
        bytes32 slot = LibStorageSlots.EXTENSION_REGISTRY_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "LibCoreExtension: restricted to admins");
        _;
    }

    function isRegistered(address _extension) external view returns (bool) {
        ExtensionRegistryStorage storage ds = load();
        return ds.extensions[_extension].version.major != 0;
    }

    function registerExtension(IExtension _extension) external onlyAdmin {
        require(address(_extension) != address(0), "LibCoreExtension: extension is zero address");
        IExtension[] memory _extensions = new IExtension[](1);
        _extensions[0] = _extension;
        registerExtensions(_extensions);
    }

    function registerExtensions(IExtension[] memory _extensions) public onlyAdmin {
        ExtensionRegistryStorage storage ds = load();
        for (uint256 i; i < _extensions.length; i++) {
            require(address(_extensions[i]) != address(0), "LibCoreExtension: extension is zero address");
            ExtensionMetadata memory metadata = _extensions[i].metadata();
            require(metadata.version.major != 0, "LibCoreExtension: invalid extension version. Must have major version >= 1");
            string memory name = metadata.name.lower();
            if(ds.extensionsByName[name] != address(0)) {
                string memory err = string(abi.encodePacked("LibCoreExtension: extension already registered: ", name));
                revert(err);
            }
            ds.extensionsByName[name] = address(_extensions[i]);
            ds.extensions[address(_extensions[i])] = metadata;
        }
    }


    function getExtension(string calldata name) external view returns (address) {
        ExtensionRegistryStorage storage ds = load();
        return ds.extensionsByName[name.lower()];
    }

    function upgradeExtension(IExtension _extension) external onlyAdmin {
        IExtension[] memory _extensions = new IExtension[](1);
        _extensions[0] = _extension;

        upgradeExtensions(_extensions);
    }

    function upgradeExtensions(IExtension[] memory _extensions) public onlyAdmin {
        ExtensionRegistryStorage storage ds = load();
        for (uint256 i; i < _extensions.length; i++) {
            require(address(_extensions[i]) != address(0), "LibCoreExtension: extension is zero address");
            ExtensionMetadata memory metadata = _extensions[i].metadata();
            string memory name = metadata.name.lower();
            address old = ds.extensionsByName[name];
            require(old != address(0), "LibCoreExtension: extension not registered");
            delete ds.extensions[old];
            ds.extensionsByName[name] = address(_extensions[i]);
            ds.extensions[address(_extensions[i])] = metadata;
        }
    }

    function unregisterExtension(address _extension) external onlyAdmin {
        ExtensionRegistryStorage storage ds = load();
        delete ds.extensions[_extension];
        ExtensionMetadata memory metadata = ds.extensions[_extension];
        string memory name = metadata.name.lower();
        delete ds.extensionsByName[name];
    }
}
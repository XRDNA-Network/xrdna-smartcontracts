// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibAccess} from '../LibAccess.sol';
import {LibRoles} from '../LibRoles.sol';
import {IExtension, ExtensionMetadata} from '../extensions/IExtension.sol';
import {LibStringCase} from '../../libraries/common/LibStringCase.sol';

struct ExtensionRegistryStorage {
    
    mapping(string => address) extensionsByName;
    mapping(address => ExtensionMetadata) extensions;
}

library LibCoreExtensionRegistry {
    using LibStringCase for string;

    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.core.v1.extension.registry.storage'))) - 1)) & bytes32(uint256(0xff));

    function load() internal pure returns (ExtensionRegistryStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
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
        return ds.extensions[_extension].version != 0;
    }

    function registerExtension(IExtension _extension) external onlyAdmin {
        ExtensionRegistryStorage storage ds = load();
        ExtensionMetadata memory metadata = _extension.metadata();
        string memory name = metadata.name.lower();
        require(ds.extensionsByName[name] == address(0), "LibCoreExtension: extension already registered");
        ds.extensionsByName[name] = address(_extension);
        ds.extensions[address(_extension)] = metadata;
    }

    function getExtension(string calldata name) external view returns (address) {
        ExtensionRegistryStorage storage ds = load();
        return ds.extensionsByName[name.lower()];
    }

    function upgradeExtension(IExtension _extension) external onlyAdmin {
        ExtensionRegistryStorage storage ds = load();
        ExtensionMetadata memory metadata = _extension.metadata();
        string memory name = metadata.name.lower();
        address old = ds.extensionsByName[name];
        require(old != address(0), "LibCoreExtension: extension not registered");
        delete ds.extensions[old];
        ds.extensionsByName[name] = address(_extension);
        ds.extensions[address(_extension)] = metadata;
    }

    function unregisterExtension(address _extension) external onlyAdmin {
        ExtensionRegistryStorage storage ds = load();
        delete ds.extensions[_extension];
        ExtensionMetadata memory metadata = ds.extensions[_extension];
        string memory name = metadata.name.lower();
        delete ds.extensionsByName[name];
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ModuleVersion} from '../modules/IModule.sol';
import {IModuleRegistry, ModuleReference} from "../core/IModuleRegistry.sol";
import {LibVersionControl} from './LibVersionControl.sol';
import {ILoopback} from './ILoopback.sol';

struct CachedModule {
    address module;
    IModuleRegistry registry;
    ModuleVersion version;
}

struct ModuleCache {
    mapping(string => CachedModule) modules;
}

/**
    * @title LibModule
    * @dev A library to manage modules and their versions. It is used to load, find, upgrade and rollback modules.
    * It is also used to delegate calls to modules. Since it is involved in module installation, it cannot be upgraded 
    * without an entire app upgrade.
 */
library LibModule {

    using LibVersionControl for CachedModule;
    
    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.module.storage.v1'))) - 1)) & bytes32(uint256(0xff));


   function load() internal pure returns (ModuleCache storage mc) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            mc.slot := slot
        }
    }

    function findRO(IModuleRegistry, string memory name) external view returns(CachedModule storage) {
        ModuleCache storage mc = load();
        CachedModule storage m = mc.modules[name];
        require(m.module != address(0), "Module not found");
        return m;
    }

    /**
     * @dev get the latest compatible module with the given name. If the module is not found or the version is not compatible,
     * it will revert. Compatible means the major version is the same and the minor version is greater or equal.
     * 
     */
    function find(IModuleRegistry registry, string memory name) external returns (CachedModule storage) {
        ModuleCache storage mc = load();
        CachedModule storage e = mc.modules[name];
        if(e.module == address(0)) {
            ModuleReference memory ref = registry.get(name);
            if(ref.module != address(0)) {
                e.module = ref.module;
                e.version = ref.version;
                e.registry = registry;
                mc.modules[name] = e;
            } else {
                string memory err = string(abi.encodePacked("LibModule: Could not find a module with name: ", name));
                revert(err);
            }
        } else if(e.canUpgradeModule()) {
            ModuleReference memory ref = registry.get(name);
            e.module = ref.module;
            e.version = ref.version;
        } 
        return e;
    }

    function upgrade(IModuleRegistry registry, string memory name) external {
        ModuleCache storage mc = load();
        CachedModule storage e = mc.modules[name];
        require(e.module != address(0), "Module not found");
        ModuleReference memory ref = registry.get(name);
        e.module = ref.module;
        e.version = ref.version;
        mc.modules[name] = e;
        e.upgradeModule(name);
    }

    function rollback(IModuleRegistry registry, string memory name) external {
        ModuleCache storage mc = load();
        CachedModule storage e = mc.modules[name];
        require(e.module != address(0), "Module not found");
        ModuleReference memory ref = registry.get(name);
        e.module = ref.module;
        e.version = ref.version;
        mc.modules[name] = e;
        e.rollbackModule(name);
    }

    function sCall(CachedModule storage entry, bytes memory data) external view returns (bytes memory) {
        bytes memory callData = abi.encodeWithSelector(ILoopback.staticLoop.selector, entry.module, data);
        (bool success, bytes memory returnData) = address(this).staticcall(callData);
        if (success) {
            return returnData;
        } else {
            // If there is a revert reason string, return it as a string
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
    }

    function dCall(CachedModule storage entry, bytes memory data) external returns (bytes memory) {
        return _doCall(entry.module, data);
    }

    function _doCall(address impl, bytes memory data) private returns (bytes memory) {
        (bool success, bytes memory returnData) = impl.delegatecall(data);
        if (success) {
            return returnData;
        } else {
            // If there is a revert reason string, return it as a string
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
    }
    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata} from '../interfaces/IExtension.sol';
import {LibStringCase} from './LibStringCase.sol';
import {LibStorageSlots} from './LibStorageSlots.sol';
import {ICoreApp} from '../interfaces/ICoreApp.sol';
import {LibVersion} from './LibVersion.sol';
import {Version} from './LibTypes.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {IExtensionResolver} from '../interfaces/IExtensionResolver.sol';

struct SelectorInfo {
    bytes4 selector;
    string name;
}

struct AddSelectorArgs {
    address impl;
    SelectorInfo[] selectors;
}

struct Selector {
    bool enabled;
    address target;
}

struct ExtensionEntry {
    bool enabled;
    ExtensionMetadata metadata;
    address extension;
    bytes4[] selectors;
}

struct ExtensionStorage {
    mapping(address => ExtensionEntry) metadata;
    mapping(bytes4 => Selector) targets;
    mapping(string => address) byName;
    IExtension[] installed;
}


library LibExtensions {

    using LibStringCase for string;
    using LibVersion for Version;


    function load() internal pure returns (ExtensionStorage storage ds) {
        bytes32 slot = LibStorageSlots.EXTENSIONS_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

    /**
     * @dev Checks whether a selector can be called
     */
     function checkCallable(bytes4 selector) external view returns (address) {
        ExtensionStorage storage ds = load();
        Selector storage s = ds.targets[selector];
        require(s.target != address(0), "LibExtension: no extension supports fn selector");
        require(s.enabled, "LibExtension: selector not enabled");
        ExtensionEntry storage ee = ds.metadata[s.target];
        require(ee.enabled, "LibExtension: extension not enabled");
        return s.target;
     }

    /**
     * @dev Called by extension manager to install extensions into its storage at deployment time.
     */
    function installExtension(IExtension impl) external {
        //we have to delegate call the install function and pass the address of the extension to the call
        //so that it uses its implementation address but the storage of this contract
        ExtensionStorage storage ds = load();
        //create an entry for the extension
        ds.metadata[address(impl)] = ExtensionEntry({
            enabled: true,
            metadata: impl.metadata(),
            extension: address(impl),
            selectors: new bytes4[](0)
        });
        ds.installed.push(impl);
        bytes memory data = abi.encodeWithSelector(IExtension.install.selector, address(impl));
        _doCall(address(impl), data);
        ExtensionMetadata memory metadata = impl.metadata();
        string memory name = metadata.name.lower();
        
        require(ds.byName[name] == address(0), "LibExtension: extension already installed");
        ds.byName[name] = address(impl);
        emit ICoreApp.ExtensionInstalled(name, metadata.version);
    }

    /**
     * @dev Called by extension manager to upgrade an extension.
     */
    function upgradeExtension(IExtension newImpl) external {
        ExtensionStorage storage ds = load();
        ExtensionMetadata memory meta = newImpl.metadata();
        string memory name = meta.name.lower();

        address currentVersion = ds.byName[name];
        require(currentVersion != address(0), "LibExtension: extension not installed");
        ExtensionMetadata memory existing = ds.metadata[currentVersion].metadata;
        require(existing.version.lessThan(meta.version), "LibExtension: new version must be greater");
        
        ExtensionEntry storage e = ds.metadata[currentVersion];
        for (uint256 i = 0; i < e.selectors.length; i++) {
            delete ds.targets[e.selectors[i]];
        }
        //create new entry for new version
        ds.metadata[address(newImpl)] = ExtensionEntry({
            enabled: true,
            metadata: newImpl.metadata(),
            extension: address(newImpl),
            selectors: new bytes4[](0)
        });

        //then install new selectors
        bytes memory data = abi.encodeWithSelector(IExtension.upgrade.selector, address(newImpl), currentVersion);
        _doCall(address(newImpl), data);
        ds.byName[name] = address(newImpl);
        delete ds.metadata[currentVersion];
        emit ICoreApp.ExtensionUpgraded(name, ds.metadata[address(newImpl)].metadata.version);
    }

    function rollbackExtension(IExtension prevVersion) external {
        ExtensionStorage storage ds = load();
        ExtensionMetadata memory meta = prevVersion.metadata();
        string memory name = meta.name.lower();
        address currentVersion = ds.byName[name];
        require(currentVersion != address(0), "LibExtension: extension not installed");
        ExtensionMetadata memory existing = ds.metadata[currentVersion].metadata;
        require(existing.version.greaterThan(meta.version), "LibExtension: new version must be less than current version");
        
        ExtensionEntry storage e = ds.metadata[currentVersion];
        for (uint256 i = 0; i < e.selectors.length; i++) {
            delete ds.targets[e.selectors[i]];
        }
        //create new entry for new version
        ds.metadata[address(prevVersion)] = ExtensionEntry({
            enabled: true,
            metadata: prevVersion.metadata(),
            extension: address(prevVersion),
            selectors: new bytes4[](0)
        });

        //then install new selectors
        bytes memory data = abi.encodeWithSelector(IExtension.upgrade.selector, address(prevVersion), currentVersion);
        _doCall(address(prevVersion), data);
        ds.byName[name] = address(prevVersion);
        delete ds.metadata[currentVersion];
        emit ICoreApp.ExtensionRolledBack(name, ds.metadata[address(prevVersion)].metadata.version);
    }

    /**
     * @dev Called by extension to add multiple selectors to its list of supported functions.
     */
    function addExtensionSelectors(AddSelectorArgs calldata args) external {
        ExtensionStorage storage ds = load();
        ExtensionEntry storage e = ds.metadata[args.impl];
        for (uint256 i = 0; i < args.selectors.length; i++) {
            SelectorInfo memory sel = args.selectors[i];
            e.selectors.push(sel.selector);
            Selector storage stored = ds.targets[sel.selector];
            if(stored.target != address(0)) {
                ExtensionEntry storage existing = ds.metadata[stored.target];
                string memory err = string(abi.encodePacked("LibExtension: extension ", 
                                            e.metadata.name, " at address: ", 
                                            Strings.toHexString(args.impl), 
                                            " attempting to reuse a selector", 
                                            sel.name, " already registered by ", 
                                            existing.metadata.name));
                revert(err);
            }
            ds.targets[sel.selector] = Selector({
                enabled: true,
                target: args.impl
            });
        }
    }

    /**
     * @dev Called by extension manager to disable all selectors associated with an extension
     */
    function disableExtension(string memory name) external {
        ExtensionStorage storage ds = load();
        address impl = ds.byName[name.lower()];
        require(impl != address(0), "LibExtension: extension not found");
        ExtensionEntry storage e = ds.metadata[impl];
        e.enabled = false;
        emit ICoreApp.ExtensionDisabled(name);
    }

    /**
     * @dev Called by extension manager to enable all selectors associated with an extension
     */
    function enableExtension(string memory name) external {
        ExtensionStorage storage ds = load();
        address impl = ds.byName[name.lower()];
        require(impl != address(0), "LibExtension: extension not found");
        ExtensionEntry storage e = ds.metadata[impl];
        e.enabled = true;
        emit ICoreApp.ExtensionEnabled(name);
    }

    /**
        * @dev Called by extension manager to disable a selector
     */
    function disableSelector(bytes4 sel) external {
        ExtensionStorage storage ds = load();
        Selector storage s = ds.targets[sel];
        require(s.target != address(0), "LibExtension: no extension supports fn selector");
        s.enabled = false;
        emit ICoreApp.SelectorDisabled(sel);
    }

    /**
        * @dev Called by extension manager to enable a selector
     */
    function enableSelector(bytes4 sel) external {
        ExtensionStorage storage ds = load();
        Selector storage s = ds.targets[sel];
        require(s.target != address(0), "LibExtension: no extension supports fn selector");
        s.enabled = true;
        emit ICoreApp.SelectorEnabled(sel);
    }

    /**
     * @dev Checks whether an extension with a specific version is installed.
     */
    function hasExtension(string memory name, Version calldata version) external view returns (bool) {
        ExtensionStorage storage ds = load();
        if(ds.byName[name.lower()] == address(0)) {
            return false;
        }
        ExtensionEntry memory e = ds.metadata[ds.byName[name.lower()]];
        if(e.enabled) {
            return e.metadata.version.equals(version);
        }
        return false; //always false is disabled
    }

    /**
     * @dev Returns the installed version of the extension.
     */
    function getExtensionVersion(string memory name) external view returns (Version memory) {
        ExtensionStorage storage ds = load();
        address ext = ds.byName[name.lower()];
        require(ext != address(0), "LibExtension: extension not found");
        ExtensionEntry storage e = ds.metadata[ext];
        return !e.enabled ? Version(0,0) : e.metadata.version;
    }

    function callExtensionWithResolver(bytes4 sel, bytes calldata data, IExtensionResolver resolver) external returns (bytes memory) {
        address target = resolver.lookup(sel);
        require(target != address(0), "LibExtension: no extension supports fn selector");
        return _doCall(target, data);
    }

    /**
     * @dev Called by core shell to execute a function call on an extension.
     */
    function callExtension(bytes4 sel, bytes calldata data) external returns (bytes memory) {
        ExtensionStorage storage ds = load();
        Selector storage s = ds.targets[sel];
        require(s.target != address(0), "LibExtension: no extension supports fn selector");
        require(s.enabled, "LibExtension: selector not enabled");
        ExtensionEntry storage e = ds.metadata[s.target];
        
        require(e.enabled, "LibExtension: extension not enabled");
        return _doCall(s.target, data);
    }

    function lowLevelCallExtension(address target, bytes calldata data) external returns (bytes memory) {
        return _doCall(target, data);
    }

    function _doCall(address target, bytes memory data) private returns (bytes memory) {
       
        (bool success, bytes memory returnData) = target.delegatecall(data);
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
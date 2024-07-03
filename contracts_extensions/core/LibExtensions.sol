// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata} from "./extensions/IExtension.sol";
import {LibStringCase} from '../libraries/common/LibStringCase.sol';
import {IExtensionManager} from './interfaces/IExtensionManager.sol';
import {IExtensionManager} from './interfaces/IExtensionManager.sol';

struct SelectorArgs {
    bool isVirtual;
    bytes4 selector;
}

struct AddSelectorArgs {
    address impl;
    SelectorArgs[] selectors;
}

struct Selector {
    bool enabled;
    bool isVirtual;
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

    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.extension.v1.storage'))) - 1)) & bytes32(uint256(0xff));

    address constant REVERT_ADDRESS = address(0x1);

    function load() internal pure returns (ExtensionStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
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
        emit IExtensionManager.ExtensionInstalled(name, metadata.version);
    }

    /**
     * @dev Called by extension manager to upgrade an extension.
     */
    function upgradeExtension(IExtension newImpl) external {
        ExtensionStorage storage ds = load();
        string memory name = newImpl.metadata().name.lower();
        address currentVersion = ds.byName[name];
        
        
        require(currentVersion != address(0), "LibExtension: extension not installed");

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
        emit IExtensionManager.ExtensionUpgraded(name, ds.metadata[address(newImpl)].metadata.version);
    }

    /**
     * @dev Called by extension to add multiple selectors to its list of supported functions.
     */
    function addExtensionSelectors(AddSelectorArgs calldata args) external {
        ExtensionStorage storage ds = load();
        ExtensionEntry storage e = ds.metadata[args.impl];
        string memory name = e.metadata.name.lower();
        for (uint256 i = 0; i < args.selectors.length; i++) {
            SelectorArgs calldata selArg = args.selectors[i];
            Selector storage stored = ds.targets[selArg.selector];
            //we only care about collisions when both stored and arg are not virtual and attempting to 
            //override each other
            if(!selArg.isVirtual && !stored.isVirtual && stored.target != address(0)) {
                string memory err = string(abi.encodePacked("LibExtension: extension", name, " attempting to reuse a selector already in use"));
                revert(err);
            }
            //require(ds.targets[selectors[i]] == address(0), "LibExtension: selector already in use");
            ds.targets[selArg.selector] = Selector({
                enabled: true,
                target: args.impl,
                isVirtual: selArg.isVirtual
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
        emit IExtensionManager.ExtensionDisabled(name);
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
        emit IExtensionManager.ExtensionEnabled(name);
    }

    /**
        * @dev Called by extension manager to disable a selector
     */
    function disableSelector(bytes4 sel) external {
        ExtensionStorage storage ds = load();
        Selector storage s = ds.targets[sel];
        require(s.target != address(0), "LibExtension: no extension supports fn selector");
        s.enabled = false;
        emit IExtensionManager.SelectorDisabled(sel);
    }

    /**
        * @dev Called by extension manager to enable a selector
     */
    function enableSelector(bytes4 sel) external {
        ExtensionStorage storage ds = load();
        Selector storage s = ds.targets[sel];
        require(s.target != address(0), "LibExtension: no extension supports fn selector");
        s.enabled = true;
        emit IExtensionManager.SelectorEnabled(sel);
    }

    /**
     * @dev Checks whether an extension with a specific version is installed.
     */
    function hasExtension(string memory name, uint256 version) external view returns (bool) {
        ExtensionStorage storage ds = load();
        if(ds.byName[name.lower()] == address(0)) {
            return false;
        }
        ExtensionEntry memory e = ds.metadata[ds.byName[name.lower()]];
        if(e.enabled) {
            return e.metadata.version == version;
        }
        return false; //always false is disabled
    }

    /**
     * @dev Returns the installed version of the extension.
     */
    function getExtensionVersion(string memory name) external view returns (uint256) {
        ExtensionStorage storage ds = load();
        address ext = ds.byName[name.lower()];
        require(ext != address(0), "LibExtension: extension not found");
        ExtensionEntry storage e = ds.metadata[ext];
        return !e.enabled ? 0 : e.metadata.version;
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

    function callExtensionWithResolver(bytes4 sel, bytes calldata data, IExtensionManager resolver) external returns (bytes memory) {
        address tgt = resolver.getImpl(sel);
        require(tgt != address(0), "LibExtension: no extension supports fn selector");
        return _doCall(tgt, data);
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

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreApp} from '../interfaces/ICoreApp.sol';
import {LibExtensions} from '../libraries/LibExtensions.sol';
import {Version} from '../libraries/LibTypes.sol';
import {ICoreExtensionRegistry} from '../ext-registry/ICoreExtensionRegistry.sol';
import {IExtension, ExtensionInitArgs} from '../interfaces/IExtension.sol';
import {LibAccess} from '../libraries/LibAccess.sol';

struct InstallExtensionArgs {
    address owner;
    address[] admins;
    string[] names;
}

abstract contract BasicShell is ICoreApp {

    ICoreExtensionRegistry public immutable extRegistry;

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "BasicShell: restricted to admins");
        _;
    }

    constructor(ICoreExtensionRegistry _extRegistry) {
        require(address(_extRegistry) != address(0), "BasicShell: extension registry cannot be zero address");
        extRegistry= _extRegistry;
    }

    function _installExtensions(InstallExtensionArgs memory args) internal {
        for (uint256 i = 0; i < args.names.length; i++) {
            if(bytes(args.names[i]).length == 0) continue;
            
            address ext = extRegistry.getExtension(args.names[i]);
            string memory err = string(abi.encodePacked("BasicShell: extension not found: ", args.names[i]));
            require(ext != address(0), err); 
            IExtension e = IExtension(ext);  
            LibExtensions.installExtension(e);
        }
        LibAccess.initAccess(args.owner, args.admins);
    }

    receive() external payable {}

     /**
     * @dev Returns true if the extension is installed
     */
    function hasExtension(string memory name, Version calldata version) external view returns (bool) {
        return LibExtensions.hasExtension(name, version);
    } 

    /**
     * @dev Returns the installed version of the extension
     */
    function getExtensionVersion(string memory name) external view returns (Version memory) {
        return LibExtensions.getExtensionVersion(name);
    }

    function withdraw(uint256 amount) external onlyAdmin {
        require(amount <= address(this).balance, "BasicShell: insufficient balance");
        payable(LibAccess.owner()).transfer(amount);
    }

    fallback() external payable {
        bytes4 selector = msg.sig;
        bytes memory result = _callFn(selector, msg.data);
        assembly {
            return(add(result, 0x20), mload(result))
        }
    }

    function _callFn(bytes4 _selector, bytes calldata data) private returns (bytes memory) {
        return LibExtensions.callExtension(_selector, data);
    }
}
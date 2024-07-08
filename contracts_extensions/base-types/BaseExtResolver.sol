// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreApp} from '../interfaces/ICoreApp.sol';
import {LibExtensions} from '../libraries/LibExtensions.sol';
import {Version} from '../libraries/LibTypes.sol';
import {ICoreExtensionRegistry} from '../ext-registry/ICoreExtensionRegistry.sol';
import {IExtension, ExtensionInitArgs} from '../interfaces/IExtension.sol';
import {LibAccess} from '../libraries/LibAccess.sol';
import {IExtensionResolver} from '../interfaces/IExtensionResolver.sol';

struct InstallExtensionArgs {
    string[] names;
}

struct BaseExtResolverConstructorArgs {
    ICoreExtensionRegistry extensionsRegistry;
    address owner;
    address[] admins;
}

abstract contract BaseExtResolver is ICoreApp, IExtensionResolver {

    ICoreExtensionRegistry public immutable extRegistry;

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "BasicExtResolver: restricted to admins");
        _;
    }

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "BasicExtResolver: restricted to owner");
        _;
    }

    constructor(BaseExtResolverConstructorArgs memory args) {
        require(address(args.extensionsRegistry) != address(0), "BaseExtResolver: extension registry cannot be zero address");
        require(args.owner != address(0), "BaseExtResolver: owner cannot be zero address");
        extRegistry= args.extensionsRegistry;
        LibAccess.initAccess(args.owner, args.admins);
    }

    function _installExtensions(InstallExtensionArgs memory args) internal {
        for (uint256 i = 0; i < args.names.length; i++) {
            if(bytes(args.names[i]).length == 0) continue;
            
            address ext = extRegistry.getExtension(args.names[i]);
            if(ext == address(0)) {
                string memory err = string(abi.encodePacked("BasicShell: extension not found: ", args.names[i]));
                revert(err);
            }
            IExtension e = IExtension(ext);  
            LibExtensions.installExtension(e);
        }
    }

    function upgradeExtension(string calldata name) external onlyAdmin {
        address e = extRegistry.getExtension(name);
        require(e != address(0), "BasicShell: extension not found");
        IExtension ext = IExtension(e);
        LibExtensions.upgradeExtension(ext);
    }

    function rollbackExtension(string calldata name) external onlyAdmin {
        address e = extRegistry.getExtension(name);
        require(e != address(0), "BasicShell: extension not found");
        IExtension ext = IExtension(e);
        LibExtensions.rollbackExtension(ext);
    }

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

    function lookup(bytes4 selector) external view override returns (address) {
        return LibExtensions.checkCallable(selector);
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return LibAccess.hasRole(role, account);
    }

    function grantRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.revokeRole(role, account);
    }

    function addSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.addSigners(signers);
    }

    function removeSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.removeSigners(signers);
    }

    function isSigner(address account) external view returns (bool) {
        return LibAccess.isSigner(account);
    }

    function isAdmin(address account) external view returns (bool) {
        return LibAccess.isAdmin(account);
    }

    function owner() external view returns (address) {
        return LibAccess.owner();
    }

    function changeOwner(address newOwner) external onlyOwner {
        LibAccess.setOwner(newOwner);
    }

    fallback() external {
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
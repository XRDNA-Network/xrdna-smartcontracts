// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import { IExtensionManager } from "../interfaces/IExtensionManager.sol";
import {Selector, LibExtensions} from "../LibExtensions.sol";
import {LibAccess} from "../LibAccess.sol";
import {LibRoles} from "../LibRoles.sol";
import {ICoreExtensionRegistry} from "../interfaces/ICoreExtensionRegistry.sol";
import {IExtension} from "../extensions/IExtension.sol";

struct CoreExtensionManagerConstructorArgs {
    address owner;
    ICoreExtensionRegistry coreExtensionRegistry;
    address[] otherAdmins;

}

/**
 * @title CoreExtensionManager
 * @dev The CoreExtensionManager contract is the main entry point for managing extensions within an individual
 * core shell contract. Since CoreShell child contracts are deployed once and delegate called by their 
 * proxy address, the storage of extension mappings would be lost for each instance clone. The extensions
 * manager, however, can be immutably assigned to the CoreShell instance allow it to be referenced by any
 * proxy and retain all extension-selector mappings.
 */
contract CoreExtensionManager is IExtensionManager {

    ICoreExtensionRegistry public immutable coreExtRegistry;

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "CoreExtensionManager: not admin");
        _;
    }

    constructor(CoreExtensionManagerConstructorArgs memory args) {
        require(args.owner != address(0), "Owner cannot be zero address");
        require(address(args.coreExtensionRegistry) != address(0), "CoreExtensionRegistry cannot be zero address"); 
        coreExtRegistry = args.coreExtensionRegistry;
        LibAccess._setOwner(args.owner);
        for (uint256 i = 0; i < args.otherAdmins.length; i++) {
            require(args.otherAdmins[i] != address(0), "Admin cannot be zero address"); 
            LibAccess._grantRevokableRole(LibRoles.ROLE_ADMIN, args.otherAdmins[i]);
        }
    }

    /**
     * @dev concrete implementation of the extension manager will install their needed extensions at 
     * deployment time.
     */
    function _installExtensions(string[] memory names) internal {
        for (uint256 i = 0; i < names.length; i++) {
            address ext = coreExtRegistry.getExtension(names[i]);
            require(address(ext) != address(0), "Extension not found");
            LibExtensions.installExtension(IExtension(ext));
        }
    }

    function getImpl(bytes4 selector) external view onlyAdmin returns (address) {
        return LibExtensions.checkCallable(selector);
    }

    function hasSelector(bytes4 selector) external view returns (bool) {
        return LibExtensions.load().targets[selector].target != address(0);
    }

    function getExtensionVersion(string memory name) external view returns (uint256) {
        return LibExtensions.getExtensionVersion(name);
    }

    function disableExtension(string memory name) external onlyAdmin {
        LibExtensions.disableExtension(name);
    }

    function enableExtension(string memory name) external onlyAdmin {
        LibExtensions.enableExtension(name);
    }

    function upgradeExtension(string memory name) external onlyAdmin {
        address ext = coreExtRegistry.getExtension(name);
        require(address(ext) != address(0), "Extension not found");
        LibExtensions.upgradeExtension(IExtension(ext));
    }

    function disableSelector(bytes4 selector) external onlyAdmin {
        LibExtensions.disableSelector(selector);
    }

    function enableSelector(bytes4 selector) external onlyAdmin {
        LibExtensions.enableSelector(selector);
    }
}
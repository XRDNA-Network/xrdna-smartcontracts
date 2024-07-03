// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../libraries/LibVectorAddress.sol';
import {Version} from '../libraries/LibTypes.sol';

struct ExtensionMetadata {
    string name;
    Version version;
}


struct ExtensionInitArgs {
    address owner;
    address owningRegistry;
    address[] admins;
}


/**
 * Extensions add functionality to a core shell base contract. The base supports common features like access control 
 * and extension management. Extensions can be installed, uninstalled, and upgraded. However, extension interfaces 
 * must ALWAYS be backward compatible. This means that function selector signatures must not change between versions 
 * and any new functions must be added and never removed. The implementation of a function can change but its signature
 * must remain the same. If a new implementation is required, remove all old logic and revert while adding a new 
 * function with a new signature. This ensures all deployed ABI's remain compatible with the core shell.
 * 
 * In addition, extensions should keep track of what functions are added between versions. This allows someone to 
 * skip versions if necessary and not lose previous functionality.
 */
interface IExtension {

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external view returns (ExtensionMetadata memory);

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external;

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external;
}
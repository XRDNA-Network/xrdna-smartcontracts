// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from '../libraries/LibTypes.sol';

interface ICoreApp {

    event ExtensionInstalled(string name, Version version);
    event ExtensionDisabled(string name);
    event ExtensionEnabled(string name);
    event ExtensionUpgraded(string name, Version version);
    event ExtensionRolledBack(string name, Version version);
    event SelectorDisabled(bytes4 selector);
    event SelectorEnabled(bytes4 selector);

    /**
     * @dev Returns true if the extension is installed
     */
    function hasExtension(string memory name, Version calldata version) external view returns (bool); 

    /**
     * @dev Returns the installed version of the extension
     */
    function getExtensionVersion(string memory name) external view returns (Version memory);
}
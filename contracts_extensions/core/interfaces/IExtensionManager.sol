// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension} from '../extensions/IExtension.sol';

interface IExtensionManager {

    event ExtensionInstalled(string name, uint256 version);
    event ExtensionDisabled(string name);
    event ExtensionEnabled(string name);
    event ExtensionUpgraded(string name, uint256 version);
    event SelectorDisabled(bytes4 selector);
    event SelectorEnabled(bytes4 selector);

    function getExtensions() external view returns (IExtension[] memory);
    function getImpl(bytes4 selector) external view returns (address);
    function getExtensionVersion(string memory name) external view returns (uint256);
    function hasSelector(bytes4 selector) external view returns (bool);
    function disableExtension(string memory name) external;
    function enableExtension(string memory name) external;
    function upgradeExtension(string memory name) external;
    function disableSelector(bytes4 selector) external;
    function enableSelector(bytes4 selector) external;
}
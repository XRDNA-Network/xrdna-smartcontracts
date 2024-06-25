// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension} from '../extensions/IExtension.sol';

interface ICoreExtensionRegistry {

    function getExtension(string calldata name) external view returns (address);

    function isRegistered(address _extension) external view returns (bool);

    function addExtension(IExtension _extension) external;

    function upgradeExtension(IExtension _extension) external;

    function removeExtension(address _extension) external;
}
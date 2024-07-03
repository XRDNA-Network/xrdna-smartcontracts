// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreApp} from './ICoreApp.sol';

interface IExtensionResolver is ICoreApp {
    function lookup(bytes4 selector) external view returns (address);
}
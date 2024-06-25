// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CoreShell, CoreShellConstructorArgs} from '../core/CoreShell.sol';
import "hardhat/console.sol";

contract ExtensionExample is CoreShell {


    constructor(CoreShellConstructorArgs memory args) CoreShell(args) {}
        
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IFundsSupport} from './IFundsSupport.sol';


interface IFundsExtension is IFundsSupport {
       function withdraw(uint256 amount) external;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from './core-libs/LibTypes.sol';

interface IUpgradeable {
    function version() external view returns (Version memory);
}
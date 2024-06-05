// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';

interface IBasicAvatar {
    function location() external view returns (VectorAddress memory);
    function setLocation(VectorAddress memory vector) external;
}
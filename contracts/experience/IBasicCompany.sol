// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {VectorAddress} from '../VectorAddress.sol';

interface IBasicCompany {
    function world() external view returns (address);
    function vectorAddress() external view returns (VectorAddress memory);
}
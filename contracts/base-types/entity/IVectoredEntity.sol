// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

interface IVectoredEntity {

    function vectorAddress() external view returns (VectorAddress memory);
}
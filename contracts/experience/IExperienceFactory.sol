// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';

interface IExperienceFactory {

    function createExperience(address company, string memory _name, VectorAddress memory vector, bytes memory data) external returns (address);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityFactory, EntityFactoryConstructorArgs} from '../../registry/factory/EntityFactory.sol';

contract RegistrarFactory is EntityFactory {
    constructor(EntityFactoryConstructorArgs memory args) EntityFactory(args){}
}
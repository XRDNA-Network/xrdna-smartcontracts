// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';

import {IExperience} from './IExperience.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IExperienceFactory} from './IExperienceFactory.sol';
import {BaseFactory} from '../BaseFactory.sol';

contract ExperienceFactory is BaseFactory, IExperienceFactory {

    address experienceRegistry;
    address expImplementation;

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function createExperience(address owner, VectorAddress memory va, bytes calldata initData) external onlyAuthorizedRegistry returns (address proxy) {
        proxy = create();
        IExperience(proxy).init(owner, va, initData);
        //console.log("Calling proxy.init", address(this));
    }
}
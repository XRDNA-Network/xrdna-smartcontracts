// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';

import {IExperience} from './IExperience.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IExperienceFactory} from './IExperienceFactory.sol';
import {BaseFactory} from '../BaseFactory.sol';
import {IBaseProxy} from '../IBaseProxy.sol';

interface INextExperienceVersion {
    function init(bytes calldata initData) external;
}

contract ExperienceFactory is BaseFactory, IExperienceFactory {

    uint256 public constant override supportsVersion = 1;
    
    address experienceRegistry;
    address expImplementation;

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function upgradeExperience(address exp, bytes calldata initData) external onlyAuthorizedRegistry {
        IExperience(exp).upgradeComplete(exp);
        INextExperienceVersion(exp).init(initData);
    }

    function createExperience(address owner, string memory _name, VectorAddress memory va, bytes calldata initData) external onlyAuthorizedRegistry returns (address proxy) {
        proxy = createProxy();
        IBaseProxy(proxy).initProxy(implementation);
        IExperience(proxy).init(owner, _name, va, initData);
        //console.log("Calling proxy.init", address(this));
    }
}
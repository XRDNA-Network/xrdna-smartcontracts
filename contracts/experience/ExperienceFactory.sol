// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';

import {IExperience} from './IExperience.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IExperienceFactory} from './IExperienceFactory.sol';
import {BaseFactory} from '../BaseFactory.sol';
import {IBaseProxy} from '../IBaseProxy.sol';

/**
 * @dev interface expected to be implemented by next version of Experience contract
 */
interface INextExperienceVersion {
    function init(bytes calldata initData) external;
}

/**
 * @title ExperienceFactory
 * @dev Factory contract for creating Experience contracts
 */
contract ExperienceFactory is BaseFactory, IExperienceFactory {

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    /**
     * @inheritdoc IExperienceFactory
     */
    function upgradeExperience(address exp, bytes calldata initData) external onlyAuthorizedRegistry {
        //to upgrade, we just need to change its underlying implementation. 
        //so first, make sure it doesn't already have the latest implementation
        address impl = IBaseProxy(exp).getImplementation();
        require(impl != implementation, "Already on the latest version");
        IExperience(exp).upgradeComplete(implementation);
        INextExperienceVersion(exp).init(initData);
    }

    /**
        * @inheritdoc IExperienceFactory
     */
    function createExperience(address owner, string memory _name, VectorAddress memory va, bytes calldata initData) external onlyAuthorizedRegistry returns (address proxy) {
        proxy = createProxy();
        IBaseProxy(proxy).initProxy(implementation);
        IExperience(proxy).init(owner, _name, va, initData);
    }
}
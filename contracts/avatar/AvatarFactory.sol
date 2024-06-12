// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatarFactory} from './IAvatarFactory.sol';
import {IAvatar} from './IAvatar.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {BaseFactory} from '../BaseFactory.sol';
import {IBaseProxy} from '../IBaseProxy.sol';

/**
 * The expected implementation of init function for the next avatar version
 */
interface INextAvatarVersion {
    function init(bytes calldata initData) external;
}

/**
 * @title AvatarFactory
 * @dev The AvatarFactory contract is used to create new Avatar contracts and upgrade existing ones.
 */
contract AvatarFactory is BaseFactory, IAvatarFactory {

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    /**
     * @inheritdoc IAvatarFactory
     */
    function upgradeAvatar(address avatar, bytes calldata initData) public override onlyAuthorizedRegistry {
        IAvatar(avatar).upgradeComplete(implementation);
        INextAvatarVersion(avatar).init(initData);
    }

    /**
     * @inheritdoc IAvatarFactory
     */
    function createAvatar(address owner, address defaultExperience, string memory username, bytes memory initData) external onlyAuthorizedRegistry returns (address proxy) {
        proxy = createProxy();
        IBaseProxy(proxy).initProxy(implementation);
        IAvatar(proxy).init(owner, defaultExperience, username, initData);
    }

    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatarFactory} from './IAvatarFactory.sol';
import {IAvatar} from './IAvatar.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';

contract AvatarFactory is IAvatarFactory, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
    address avatarRegistry;
    address implementation;

    modifier onlyRegistry {
        require(avatarRegistry != address(0), 'AvatarFactory: registry not set');
        require(msg.sender == avatarRegistry, 'AvatarFactory: only registry allowed');
        _;
    }

    constructor(address mainAdmin, address[] memory admins) {
        require(mainAdmin != address(0), 'AvatarFactory: main admin address cannot be 0');
        require(_grantRole(DEFAULT_ADMIN_ROLE, mainAdmin), 'AvatarFactory: default admin role grant failed');
        require(_grantRole(ADMIN_ROLE, mainAdmin), 'AvatarFactory: admin role grant failed');
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), 'AvatarFactory: admin address cannot be 0');
            require(_grantRole(ADMIN_ROLE, admins[i]), 'AvatarFactory: admin role grant failed');
        }
    }

    function setAvatarRegistry(address registry) external onlyRole(ADMIN_ROLE) {
        require(registry != address(0), 'AvatarFactory: zero address not valid');
        avatarRegistry = registry;
    }

    function setAvatarImplementation(address impl) public onlyRole(ADMIN_ROLE) {
        require(impl != address(0), 'AvatarFactory: zero address not valid');
        implementation = impl;
    }

    function createAvatar(address owner, address defaultExperience, bytes memory initData) external onlyRegistry returns (address proxy) {

        require(implementation != address(0), "AvatarFactory: implementation not set");

        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(implementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
        IAvatar(proxy).init(owner, defaultExperience, initData);
    }

    function isAvatarClone(address query) public view returns (bool result) {
        address target = implementation;
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';

import {IExperience} from './IExperience.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IExperienceFactory} from './IExperienceFactory.sol';

contract ExperienceFactory is IExperienceFactory, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address experienceRegistry;
    address expImplementation;

    modifier onlyRegistry() {
        require(experienceRegistry != address(0), "ExperienceFactory: registry not set");
        require(msg.sender == experienceRegistry, "ExperienceFactory: only registry allowed");
        _;
    }

    constructor(address[] memory admins) {
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "ExperienceFactory: admin address cannot be 0");
            require(_grantRole(ADMIN_ROLE, admins[i]), "ExperienceFactory: admin role grant failed");
        }
    }

    function setExperienceRegistry(address registry) external onlyRole(ADMIN_ROLE) {
        require(registry != address(0), "ExperienceFactory: zero address not valid");
        experienceRegistry = registry;
    }

    function setImplementation(address impl) external onlyRole(ADMIN_ROLE) {
        require(impl != address(0), "ExperienceFactory: zero address not valid");
        expImplementation = impl;
    }

    function createExperience(address owner, VectorAddress memory va, bytes calldata initData) external  onlyRegistry() returns (address proxy) {
        require(expImplementation != address(0), "ExperienceFactory: implementation not set");

        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(expImplementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
        IExperience(proxy).init(owner, va, initData);
        //console.log("Calling proxy.init", address(this));
    }

    function isExperienceClone(address query) public view returns (bool result) {
        address target = expImplementation;
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
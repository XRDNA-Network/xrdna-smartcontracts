// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IPortalCondition} from '../portal/IPortalCondition.sol';
contract TestCondition is IPortalCondition {

    mapping(address => bool) public allowed;

    function canJump(address experience, address sourceWorld, address sourceCompany, address sourceExperience, address avatar) external returns (bool) {
        return allowed[avatar];
    }

    function setCanJump(address avatar, bool _canJump) public {
        allowed[avatar] = _canJump;
    }
}
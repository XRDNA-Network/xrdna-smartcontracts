// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IPortalCondition, JumpEvaluationArgs} from '../portal/IPortalCondition.sol';
contract TestCondition is IPortalCondition {

    mapping(address => bool) public allowed;

    function canJump(JumpEvaluationArgs memory args) external view returns (bool) {
        return allowed[args.avatar];
    }

    function setCanJump(address avatar, bool _canJump) public {
        allowed[avatar] = _canJump;
    }
}
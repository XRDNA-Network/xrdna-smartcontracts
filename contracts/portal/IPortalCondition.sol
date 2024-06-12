// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IPortalCondition {
    function canJump(address experience, address sourceWorld, address sourceCompany, address sourceExperience, address avatar) external returns (bool);
}
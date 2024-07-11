// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct JumpEvaluationArgs {
    address destinationExperience;
    address sourceWorld;
    address sourceCompany;
    address sourceExperience;
    address avatar;
}

/**
 * @dev Interface for portal conditions. Conditions allow additional rules to be attached
 * to a portal, which must be satisfied before a jump can be made.
 */
interface IPortalCondition {
    /**
     * @dev Returns whether the given avatar can jump to the destination experience from 
     * the source experience, company, and world.
     */
    function canJump(JumpEvaluationArgs memory args) external returns (bool);
}
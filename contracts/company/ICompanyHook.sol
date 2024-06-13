// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AddExperienceArgs} from './ICompany.sol';

/**
 * @title ICompanyHook
  * @dev Interface for a hook that can be called by a company to validate certain company
    * operations. Any hook function that returns false will prevent the action from occurring.
 */
interface ICompanyHook {

    /**
     * @dev Called before adding an experience to a world.
     */
    function beforeAddExperience(AddExperienceArgs memory args) external returns (bool);

    /**
     * @dev Called before minting an asset.
     */
    function beforeMint(address asset, address to, uint256 amount) external returns (bool);
    function beforeRevoke(address asset, address holder, uint256 amountOrTokenId) external returns (bool);
}
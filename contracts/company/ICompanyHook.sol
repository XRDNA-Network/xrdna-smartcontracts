// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AddExperienceArgs} from './ICompany.sol';

interface ICompanyHook {

    function beforeAddExperience(AddExperienceArgs memory args) external returns (bool);
    function beforeMint(address asset, address to, uint256 amount) external returns (bool);
    function beforeRevoke(address asset, address holder, uint256 amountOrTokenId) external returns (bool);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CompanyInitArgs} from './ICompany.sol';

interface ICompanyFactory {
    
    function createCompany(CompanyInitArgs memory request) external returns (address);
}
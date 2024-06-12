// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CompanyInitArgs} from './ICompany.sol';
import {IBaseFactory} from '../IBaseFactory.sol';

interface ICompanyFactory is IBaseFactory {
    
    function upgradeCompany(address company, bytes calldata initData) external;
    function createCompany(CompanyInitArgs memory request) external returns (address);
}
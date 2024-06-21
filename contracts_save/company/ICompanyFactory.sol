// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CompanyInitArgs} from './ICompany.sol';
import {IBaseFactory} from '../IBaseFactory.sol';

/**
 * @title ICompanyFactory
 * @dev Interface for a factory that creates and upgrades companies.
 */
interface ICompanyFactory is IBaseFactory {
    
    /**
     * @dev Upgrades a company to a new implementation.
     */
    function upgradeCompany(address company, bytes calldata initData) external;

    /**
     * @dev Creates a new company.
     */
    function createCompany(CompanyInitArgs memory request) external returns (address);
}
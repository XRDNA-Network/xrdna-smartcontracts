// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICompanyFactory} from './ICompanyFactory.sol';
import {ICompany, CompanyInitArgs} from './ICompany.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {BaseFactory} from '../BaseFactory.sol';
import {IBaseProxy} from '../IBaseProxy.sol';

/**
 * Future versions of company must implement this init interface for any new 
 * initial state params.
 */
interface INextCompanyVersion {
    function init(bytes calldata initData) external;
}

/**
 * Implementation of the company factory.
 */
contract CompanyFactory is BaseFactory, ICompanyFactory {

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    /**
     * @inheritdoc ICompanyFactory
     */
    function upgradeCompany(address company, bytes calldata initData) public override onlyAuthorizedRegistry {
        ICompany(company).upgradeComplete(implementation);
        INextCompanyVersion(company).init(initData);
    }

    /**
     * @inheritdoc ICompanyFactory
     */
    function createCompany(CompanyInitArgs memory args) public onlyAuthorizedRegistry returns (address) {
        address proxy = createProxy(); 
        IBaseProxy(proxy).initProxy(implementation);
        ICompany(proxy).init(args);
        return proxy;
    }
}
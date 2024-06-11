// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICompanyFactory} from './ICompanyFactory.sol';
import {ICompany, CompanyInitArgs} from './ICompany.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {BaseFactory} from '../BaseFactory.sol';
import {IBaseProxy} from '../IBaseProxy.sol';

interface INextCompanyVersion {
    function init(bytes calldata initData) external;
}

contract CompanyFactory is BaseFactory, ICompanyFactory {
    uint256 public constant override supportsVersion = 1;

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function upgradeCompany(address company, bytes calldata initData) public override onlyAuthorizedRegistry {
        ICompany(company).upgradeComplete(implementation);
        INextCompanyVersion(company).init(initData);
    }

    function createCompany(CompanyInitArgs memory args) public onlyAuthorizedRegistry returns (address) {
        address proxy = createProxy(); 
        IBaseProxy(proxy).initProxy(implementation);
        ICompany(proxy).init(args);
        return proxy;
    }
}
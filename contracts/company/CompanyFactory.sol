// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICompanyFactory} from './ICompanyFactory.sol';
import {ICompany, CompanyInitArgs} from './ICompany.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {BaseFactory} from '../BaseFactory.sol';

contract CompanyFactory is BaseFactory, ICompanyFactory {
     constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function createCompany(CompanyInitArgs memory args) public onlyAuthorizedRegistry returns (address) {
        address proxy = create();
        ICompany(proxy).init(args);
        return proxy;
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import { ICompanyFactory } from "./ICompanyFactory.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CompanyFactory is ICompanyFactory, AccessControl {
    address public companyImplementation;
    address public companyRegistry;

    event CompanyCreated(address company);
    event CompanyRegistryChanged(address indexed oldRegistry, address indexed newRegistry);

    modifier onlyCompanyRegistry() {
        require(msg.sender == companyRegistry, "CompanyFactory: caller is not the company registry");
        _;
    }

    function setImplementation(address _companyImplementation) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_companyImplementation != address(0), "CompanyFactory: implementation cannot be zero address");
        companyImplementation = _companyImplementation;
    }

    function setCompanyRegistry(address _companyRegistry) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_companyRegistry != address(0), "CompanyFactory: company registry cannot be zero address");
        companyRegistry = _companyRegistry;
        emit CompanyRegistryChanged(companyRegistry, _companyRegistry);
    }

    function createCompany(address owner, bytes calldata initData) external onlyCompanyRegistry returns (address) {
        require(companyImplementation != address(0), "CompanyFactory: company implementation not set");
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(companyImplementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf300)
            proxy := create(0, clone, 0x37)
        }
        IBasicCompany(proxy).init(owner, initData);
        emit CompanyCreated(address(proxy));
    }
    function isCompanyClone(address query) public view override returns (bool result) {
        bytes20 targetBytes = bytes20(companyImplementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}
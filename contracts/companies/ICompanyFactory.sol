// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


interface ICompanyFactory {
    function createCompany(address owner, bytes calldata initData) external returns (address);
    function isCompanyClone(address company) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


interface ICompanyRegistry {
    function isCompany(address company) external view returns (bool);
    function createCompany(address owner, bytes calldata initData) external returns (address company);
    function register(address world, address company, bool tokensToOwner) external payable;
}
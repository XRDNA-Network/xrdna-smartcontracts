// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface ICompanyRegistry {

    function isRegisteredCompany(address company) external view returns (bool);
}
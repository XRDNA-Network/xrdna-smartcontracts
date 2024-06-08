// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';


struct CompanyRegistrationRequest {

    //whether to send any attached tokens to the owner wallet or company contract
    bool sendTokensToCompanyOwner;

    //the address of the company owner
    address owner;

    //the vector address of the company
    VectorAddress vector;

    //initialization data to pass to the company contract
    bytes initData;

    //the name of the company, must be globally unique, case-insensitive
    string name;
}

interface ICompanyRegistry {

    event CompanyRegistered(address indexed company, VectorAddress indexed);

    function setCompanyFactory(address factory) external;
    function setWorldRegistry(address registry) external;
    function isRegisteredCompany(address company) external view returns (bool);
    function registerCompany(CompanyRegistrationRequest memory request) external payable returns (address);
    function upgradeCompany(bytes calldata initData) external;
}
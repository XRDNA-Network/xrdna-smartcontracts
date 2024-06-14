// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';


/**
 * @dev Args to register a company in the registry. This is used by the World contract
 * to register a new company.
 */
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

/**
 * @title ICompanyRegistry
    * @dev Interface for a registry of companies. The registry is responsible for
    * deploying new companies and keeping track of the current version of the company
    * implementations. The registry is also responsible for upgrading companies to a new
    * version.
 */
interface ICompanyRegistry {

    event CompanyRegistered(address indexed company, VectorAddress indexed);
    event CompanyRemoved(address indexed company);
    
    /**
     * @dev Returns the current version of the company implementation. This is derived
     * from the company factory.
     */
    function currentCompanyVersion() external view returns (uint256);

    /**
     * @dev Sets the company factory that is used to deploy new companies. Only admins 
     * can change this.
     */
    function setCompanyFactory(address factory) external;

    /**
     * @dev Sets the world registry that is used to look up world information. Only admins
     * can change this.
     */
    function setWorldRegistry(address registry) external;

    /**
     * @dev Returns whether an address is a verified company contract.
     */
    function isRegisteredCompany(address company) external view returns (bool);

    /**
     * @dev Registers a new company in the company register. This must be called by a World
     * contract to ensure world authorization is checked.
     */
    function registerCompany(CompanyRegistrationRequest memory request) external payable returns (address);
    
    /**
     * @dev Removes a company from the company registry. This can only be called by a world admin.
     */
    function removeCompany(address company) external;

    /**
     * @dev Upgrades a company to a new version. This is called by the company contract 
     * to ensure authorization is checked prior to upgrading.
     */
    function upgradeCompany(bytes calldata initData) external;
}
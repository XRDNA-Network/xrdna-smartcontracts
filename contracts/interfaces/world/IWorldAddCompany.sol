
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';

struct NewCompanyArgs {

    //whether any attached tokens for registration are sent to the company owner address or
    //to the company contract itself
    bool sendTokensToOwner;

    //owner of the company contract
    address owner;

    //company's globally unique name
    string name;

    //the terms of the company's registration
    RegistrationTerms terms;

    //signature of the company owner on the terms and registrar address
    bytes ownerTermsSignature;

    //signature expiration time in seconds
    uint256 expiration;

    //company contract init data, if any
    bytes initData;
}

interface IWorldAddCompany {

    event WorldAddedCompany(address indexed company, address indexed owner);
    event WorldDeactivatedCompany(address indexed company, string reason);
    event WorldReactivatedCompany(address indexed company);
    event WorldRemovedCompany(address indexed company, string reason);

    /**
     * @dev Registers a new company contract. Must be called by a world signer
     */
    function registerCompany(NewCompanyArgs memory args) external payable returns (address company);

    /**
     * @dev Deactivates a company contract. Must be called by a world signer
     */
    function deactivateCompany(address company, string calldata reason) external;

    /**
     * @dev Reactivates a company contract. Must be called by a world signer
     */
    function reactivateCompany(address company) external;

    /**
     * @dev Removes a company contract. Must be called by a world signer
     */
    function removeCompany(address company, string calldata reason) external;
}
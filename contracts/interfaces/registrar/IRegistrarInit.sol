// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from "../../libraries/common/LibRegistration.sol";

/**
 * @dev Arguments for creating a new registrar
 */
struct RegistrarInitArgs {

    //whether to send any registration attached tokens to the registrar owner
    //or registrar contract itself
    bool sendTokensToOwner;

    //globally unique name of the registrar
    string name;

    //the owner to assign to the registrar contract and transfer
    //any initial tokens to if required
    address owner;

    //the registration terms for the registrar
    RegistrationTerms worldRegistrationTerms;
}

interface IRegistrarInit {
    
    function init(RegistrarInitArgs calldata args) external;
}
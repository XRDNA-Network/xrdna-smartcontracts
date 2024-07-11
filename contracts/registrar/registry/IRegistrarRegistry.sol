// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibRegistration.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';

//args for creating non-removable registrar
struct CreateNonRemovableRegistrarArgs {

    //whether to send tokens to the registrar owner wallet or registrar contract
    bool sendTokensToOwner;

    //owner of the registrar
    address owner;

    //unique name for the registrar
    string name;

    //custom init data for the registrar
    bytes initData;
}

//args for creating a removable registrar
struct CreateRegistrarArgs {

    //whether to send tokens to the registrar owner wallet or registrar contract
    bool sendTokensToOwner;

    //owner of the registrar
    address owner;

    //signature expiration time
    uint256 expiration;

    //registration terms
    RegistrationTerms terms;

    //unique name for the registrar
    string name;

    //custom init data for the registrar
    bytes initData;

    //signature of the terms by the owner agreeing to terms and authority
    bytes ownerTermsSignature;
}

interface IRegistrarRegistry is IRemovableRegistry {

    /**
     * @dev Creates a new non-removable registrar with the given arguments.
     */
    function createNonRemovableRegistrar(CreateNonRemovableRegistrarArgs calldata args) external payable returns (address);

    /**
     * @dev Creates a new removable registrar with the given arguments. The registrar registry is 
     * the terms authority for the registrar.
     */
    function createRemovableRegistrar(CreateRegistrarArgs calldata args) external payable returns (address);

    /**
     * @dev When regsitrars renew registration, any fees are passed to this contract as the registrar's
     * terms owner. This function allows the registry owner to withdraw funds collected by the registry.
     */
    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';

struct NewWorldArgs {

    //whether any attached tokens for registration are sent to the world owner address or
    //to the world contract itself
    bool sendTokensToOwner;

    //owner of the world contract
    address owner;

    //world's spatial vector address assigned by registrar
    VectorAddress baseVector;

    //world's globally unique name
    string name;

    //the terms of the world's registration
    RegistrationTerms terms;

    //signature of the world owner on the terms and registrar address
    bytes ownerTermsSignature;

    //signature expiration time in seconds
    uint256 expiration;

    //signature of the vector address authority that issued the vector address to the registrar
    bytes vectorAuthoritySignature;

    //world contract init data, if any
    bytes initData;
}

struct RegistrarInitArgs {
    address owner;
    address[] admins;
}

interface IRegistrar is IAccessControl, IRemovableEntity, ITermsOwner  {

    event RegistrarAddedWorld(address indexed world, address indexed owner);
    event RegistrarDeactivatedWorld(address indexed world, string reason);
    event RegistrarReactivatedWorld(address indexed world);
    event RegistrarRemovedWorld(address indexed world, string reason);

    function init(string calldata name, bytes calldata initData) external;

    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(NewWorldArgs memory args) external payable returns (address world);

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world, string calldata reason) external;

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external;

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world, string calldata reason) external;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableEntity} from '../../modules/registration/IRemovableEntity.sol';
import {ITermsOwner} from '../../modules/registration/ITermsOwner.sol';
import {VectorAddress} from '../../core/VectorAddress.sol';
import {IFundable} from '../../entity/IFundable.sol';

struct CreateWorldArgs {

    //whether any attached tokens for registration are sent to the world owner address or
    //to the world contract itself
    bool sendTokensToWorldOwner;

    //owner of the world contract
    address owner;

    //world's spatial vector address assigned by registrar
    VectorAddress baseVector;

    //world's globally unique name
    string name;

    //signature of the vector address authority that issued the vector address to the registrar
    bytes vectorAuthoritySignature;

    //world contract init data
    bytes initData;
}

interface IRegistrar is IRemovableEntity, ITermsOwner, IFundable  {

    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(CreateWorldArgs memory args) external payable returns (address world);

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world) external;

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external;

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world) external;
 
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {IRegistrarRegistry} from '../interfaces/IRegistrarRegistry.sol';
import {Version, RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {LibTermsOwner} from '../../core-libs/LibTermsOwner.sol';
import {LibAccess} from '../../core-libs/LibAccess.sol';
import {CreateEntityArgs} from '../../base-types/registry/IRegistry.sol';
import {LibRegistry, RegistrationRequest} from '../../core-libs/LibRegistry.sol';
import {VectorAddress} from '../../core-libs/LibVectorAddress.sol';
import {IRemovableEntity} from '../../entity-libs/interfaces/IRemovableEntity.sol';
import {LibEntityRemoval} from '../../entity-libs/removal/LibEntityRemoval.sol';
import {CommonInitArgs} from '../../entity-libs/interfaces/IRegisteredEntity.sol';

import "hardhat/console.sol";

contract RegistrarRegistry is BaseRegistry, IRegistrarRegistry {

    bytes32 constant REGISTRAR_TERMS = keccak256("REGISTRAR_TERMS");

    function version() public pure override returns (Version memory) {
        return Version(1, 0);
    }

    function isStillActive() public pure returns (bool) {
        return true; //registry always active
    }

    function isTermsOwnerSigner(address a) public view returns (bool) {
        return LibAccess.isAdmin(a) || LibAccess.isSigner(a);
    }

    function createRegistrar(CreateEntityArgs calldata args) public payable onlySigner returns (address)  {
        _verifyNewEntityTermsSignature(args);

        VectorAddress memory v = VectorAddress({
            x: "",
            y: "",
            z: "",
            t: 0,
            p: 0,
            p_sub: 0
        });

        CommonInitArgs memory initArgs = CommonInitArgs({
            owner: args.owner,
            name: args.name,
            termsOwner: address(this),
            initData: args.initData,
            vector: v
        });

        RegistrationRequest memory req = RegistrationRequest({
            terms: args.terms,
            initData: initArgs
        });

        address a = LibRegistry.registerRemovable(req);

        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(a).transfer(msg.value);
            }
        }
        return a;
    }

    /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) public onlySigner {
        LibEntityRemoval.deactivateEntity(entity, reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) public onlySigner {
        LibEntityRemoval.reactivateEntity(entity);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) public onlySigner {
        LibEntityRemoval.removeEntity(entity, reason);
    }
    
}
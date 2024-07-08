// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {BaseVectoredRegistry} from '../../base-types/registry/BaseVectoredRegistry.sol';
import {IWorldRegistry, CreateWorldArgs} from './IWorldRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {IWorld} from '../instance/IWorld.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';

contract WorldRegistry is BaseRemovableRegistry, BaseVectoredRegistry, IWorldRegistry {

    using LibVectorAddress for VectorAddress;

    IRegistrarRegistry public immutable registrarRegistry;

    constructor(address _registrarRegistry) {
        require(_registrarRegistry != address(0), "RegistrarRegistry: invalid registrar registry"); 
        registrarRegistry = IRegistrarRegistry(_registrarRegistry);
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    modifier onlyActiveRegistrar {
        require(registrarRegistry.isRegistered(msg.sender), "RegistrarRegistry: registrar not registered");
        require(IRegistrar(msg.sender).isEntityActive(), "RegistrarRegistry: registrar not active");
        _;
    }

    function isVectorAddressAuthority(address a) public view returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    function addVectorAddressAuthority(address a) public onlyAdmin {
        LibAccess.grantRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    function removeVectorAddressAuthority(address a) public onlyAdmin {
        LibAccess.revokeRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    function createWorld(CreateWorldArgs calldata args) public payable override onlyActiveRegistrar returns (address) {
        require(args.expiration > block.timestamp, "RegistrarRegistry: signature expired");
        require(args.terms.gracePeriodDays > 0, "RegistrarRegistry: grace period must be greater than 0");
        
        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "RegistrarRegistry: entity implementation not set");
        
        //false,false means p and p_sub must be zero
        args.vector.validate(false, false);

        address signer = args.vector.getSigner(msg.sender, args.vectorAuthoritySignature);
        require(isVectorAddressAuthority(signer), "WorldRegistry: vector signer is not a valid vector address authority");

        TermsSignatureVerification memory verification = TermsSignatureVerification({
            owner: args.owner,
            termsOwner: address(this),
            terms: args.terms,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);

        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "RegistrarRegistration: entity cloning failed");
        IWorld(entity).init(args.name, args.vector, args.initData);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: entity,
            terms: args.terms,
            vector: args.vector
        });
        LibRegistration.registerRemovableVectoredEntity(regArgs);
         if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(entity).transfer(msg.value);
            }
        }

        emit RegistryAddedEntity(entity, args.owner);

        return entity;
    }
}
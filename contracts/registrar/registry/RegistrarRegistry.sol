// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {LibAccess } from '../../libraries/LibAccess.sol';
import {IRegistrarRegistry, CreateNonRemovableRegistrarArgs, CreateRegistrarArgs} from './IRegistrarRegistry.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {IRegistrar} from '../instance/IRegistrar.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';


contract RegistrarRegistry is BaseRemovableRegistry {

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    function version() external pure override returns(Version memory) {
        return Version(1, 0);
    }

    function createNonRemovableRegistrar(CreateNonRemovableRegistrarArgs calldata args) external payable onlySigner returns (address) {
        FactoryStorage storage fs = LibFactory.load();
        
        require(fs.proxyImplementation != address(0), "RegistrarRegistration: proxy implementation not set");
        require(fs.entityImplementation != address(0), "RegistrarRegistry: entity implementation not set");
        address proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "RegistrarRegistration: entity cloning failed");

        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        IRegistrar(proxy).init(args.name, args.owner, args.initData);
        _registerNonRemovableEntity(proxy);
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(proxy).transfer(msg.value);
            }
        }

        emit RegistryAddedEntity(proxy, args.owner);

        return proxy;
    }

    function createRemovableRegistrar(CreateRegistrarArgs calldata args) external payable onlySigner returns (address) {
        require(args.expiration > block.timestamp, "RegistrarRegistry: signature expired");
        require(args.terms.gracePeriodDays > 0, "RegistrarRegistry: grace period must be greater than 0");
        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "RegistrarRegistry: entity implementation not set");
        
        
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
        IRegistrar(entity).init(args.name, args.owner, args.initData);
        _registerRemovableEntity(entity, args.terms);
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


// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {BaseVectoredRegistry} from '../../base-types/registry/BaseVectoredRegistry.sol';
import {IWorldRegistry, ChangeControllerArgs, CreateWorldArgs} from './IWorldRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {LibRegistration, RegistrationStorage, TermedRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {IWorld} from '../instance/IWorld.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {Version} from '../../libraries/LibTypes.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';

struct WorldRegistryConstructorArgs {
    address registrarRegistry;
}

contract WorldRegistry is BaseRemovableRegistry, BaseVectoredRegistry, IWorldRegistry {

    using LibVectorAddress for VectorAddress;
    using MessageHashUtils for bytes;

    IRegistrarRegistry public immutable registrarRegistry;

    constructor(WorldRegistryConstructorArgs memory args)  {  
        require(args.registrarRegistry != address(0), "RegistrarRegistry: invalid registrar registry");
        registrarRegistry = IRegistrarRegistry(args.registrarRegistry); 
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

    function version() external pure override returns(Version memory) {
        return Version(1, 0);
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
        require(fs.proxyImplementation != address(0), "RegistrarRegistry: proxy implementation not set");

        //false,false means p and p_sub must be zero
        args.vector.validate(false, false);

        address signer = args.vector.getSigner(msg.sender, args.vectorAuthoritySignature);
        require(isVectorAddressAuthority(signer), "WorldRegistry: vector signer is not a valid vector address authority");

        TermsSignatureVerification memory verification = TermsSignatureVerification({
            owner: args.owner,
            termsOwner: msg.sender,
            terms: args.terms,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);

        address proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "RegistrarRegistration: entity cloning failed");
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        IWorld(proxy).init(args.name, args.owner, args.vector, args.initData);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: proxy,
            terms: args.terms,
            vector: args.vector
        });
        LibRegistration.registerRemovableVectoredEntity(regArgs);
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

    function changeControllerWithTerms(ChangeControllerArgs calldata args) external override onlyActiveRegistrar {

        _verifyMigrationSigs(args);
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        address old = tr.owner;
        tr.owner = msg.sender;
        tr.terms = args.newTerms;
        tr.lastRenewed = block.timestamp;
        tr.deactivationTime = 0;
        emit RegistrarChangedForWorld(args.entity, old, msg.sender);
    }

    function _verifyMigrationSigs(ChangeControllerArgs calldata args) internal view {
        require(args.expiration > block.timestamp, "Registrar: migration signature expired");
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        ITermsOwner owner = ITermsOwner(tr.owner);

        bytes32 hash = args.newTerms.coveragePeriodDays > 0 && args.newTerms.fee > 0 ? keccak256(abi.encode(args.entity, msg.sender, args.expiration, args.newTerms.fee, args.newTerms.coveragePeriodDays, args.newTerms.gracePeriodDays)) :
                        keccak256(abi.encode(args.entity, msg.sender, args.expiration));
        bytes32 oldHash = keccak256(abi.encode(args.entity, msg.sender, args.expiration));
        bytes memory b = new bytes(32);
        bytes memory oldB = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
            mstore(add(oldB, 32), oldHash) // set the bytes data
        }
        //make sure signer is a signer for the destination experience's company
        bytes32 sigHash = b.toEthSignedMessageHash();
        bytes32 oldSigHash = oldB.toEthSignedMessageHash();
        
        if(args.oldControllerSignature.length == 0) {
            require(!owner.isStillActive(), "Registrar: current registrar is active but no signature provided");
        } else {
            address r = ECDSA.recover(oldSigHash, args.oldControllerSignature);
            require(owner.isTermsOwnerSigner(r), "Registrar: current registrar signature invalid");
        }
        address w = ECDSA.recover(sigHash, args.entitySignature);
        require(IWorld(args.entity).isSigner(w), "Registrar: entity signature invalid");
    }
}
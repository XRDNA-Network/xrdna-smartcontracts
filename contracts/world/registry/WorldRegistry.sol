// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {BaseVectoredRegistry} from '../../base-types/registry/BaseVectoredRegistry.sol';
import {IWorldRegistry, ChangeRegistrarArgs, CreateWorldArgs} from './IWorldRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {LibRegistration, RegistrationStorage, TermedRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {IWorld, WorldInitArgs} from '../instance/IWorld.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {Version} from '../../libraries/LibVersion.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';

struct WorldRegistryConstructorArgs {
    address registrarRegistry;
}

/**
 * @title WorldRegistry
 * @dev A registry for creating and managing worlds
 */
contract WorldRegistry is BaseRemovableRegistry, BaseVectoredRegistry, IWorldRegistry {

    using MessageHashUtils for bytes;
    using LibVectorAddress for VectorAddress;

    IRegistrarRegistry public immutable registrarRegistry;


    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    modifier onlyActiveRegistrar {
        require(registrarRegistry.isRegistered(msg.sender), "RegistrarRegistry: registrar not registered");
        require(IRegistrar(msg.sender).isEntityActive(), "RegistrarRegistry: registrar not active");
        _;
    }

    //called when logic contract is deployed to set immutable registry value
    constructor(WorldRegistryConstructorArgs memory args)  {  
        require(args.registrarRegistry != address(0), "RegistrarRegistry: invalid registrar registry");
        registrarRegistry = IRegistrarRegistry(args.registrarRegistry); 
    }


    function version() external pure override returns(Version memory) {
        return Version(1, 0);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function isVectorAddressAuthority(address a) public view returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function addVectorAddressAuthority(address a) public onlyAdmin {
        LibAccess.grantRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function removeVectorAddressAuthority(address a) public onlyAdmin {
        LibAccess.revokeRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function createWorld(CreateWorldArgs calldata args) public override onlyActiveRegistrar nonReentrant returns (address) {
         
        //make sure proxy and logic has been set
        FactoryStorage storage fs = LibFactory.load();
        require(fs.entityImplementation != address(0), "RegistrarRegistry: entity implementation not set");
        require(fs.proxyImplementation != address(0), "RegistrarRegistry: proxy implementation not set");

        address signer = args.vector.getSigner(msg.sender, args.vectorAuthoritySignature);
        require(isVectorAddressAuthority(signer), "WorldRegistry: vector signer is not a valid vector address authority");

        //verify terms sigs
        TermsSignatureVerification memory verification = TermsSignatureVerification({
            owner: args.owner,
            termsOwner: msg.sender,
            terms: args.terms,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);

        //clone the proxy
        address proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "RegistrarRegistration: entity cloning failed");

        //set logic
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        //initialize state
        WorldInitArgs memory wArgs = WorldInitArgs({
            name: args.name,
            owner: args.owner,
            termsOwner: msg.sender,
            vector: args.vector,
            initData: args.initData
        });
        IWorld(proxy).init(wArgs);

        //register in storage
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: proxy,
            termsOwner: msg.sender,
            terms: args.terms,
            vector: args.vector
        });
        LibRegistration.registerRemovableVectoredEntity(regArgs);
         

        emit RegistryAddedEntity(proxy, args.owner);

        return proxy;
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function changeRegistrarWithTerms(ChangeRegistrarArgs calldata args) external override onlyActiveRegistrar nonReentrant {

        //verify signatures for migrating to new registrar
        _verifyMigrationSigs(args);
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        address old = tr.owner;

        //new registrar calls this contract so they're the new terms owner
        tr.owner = msg.sender;

        //set new terms
        tr.terms = args.newTerms;

        //reset terms start time
        tr.lastRenewed = block.timestamp;

        if(tr.deactivationTime > 0) {
            //tell world to reactivate
            IWorld(args.entity).reactivate();
            tr.deactivationTime = 0;
        }
        
        emit RegistrarChangedForWorld(args.entity, old, msg.sender);
    }

    /**
     * @dev Verify signatures when migrating to a new registrar
     */
    function _verifyMigrationSigs(ChangeRegistrarArgs calldata args) internal view {
        //make sure migration sig has not expired
        require(args.expiration > block.timestamp, "Registrar: migration signature expired");
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        ITermsOwner to = ITermsOwner(tr.owner);

        bytes32 hash = keccak256(abi.encode(msg.sender, args.expiration, args.newTerms.fee, args.newTerms.coveragePeriodDays, args.newTerms.gracePeriodDays));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        //make sure signer is a signer for the destination experience's company
        bytes32 sigHash = b.toEthSignedMessageHash();
        address w = ECDSA.recover(sigHash, args.entitySignature);
        require(IWorld(args.entity).isAdmin(w), "Registrar: entity signature invalid");
        
        if(args.oldRegistrarSignature.length == 0) {
            require(!to.isStillActive(), "Registrar: current registrar is active but no signature provided");
        } else {
            bytes32 oldHash = keccak256(abi.encode(args.entity, msg.sender, args.expiration));
            bytes memory oldB = new bytes(32);
            assembly {
                mstore(add(oldB, 32), oldHash) // set the bytes data
            }
            bytes32 oldSigHash = oldB.toEthSignedMessageHash();
            address r = ECDSA.recover(oldSigHash, args.oldRegistrarSignature);
            require(to.isTermsOwnerSigner(r), "Registrar: current registrar signature invalid");
        }
    }
}
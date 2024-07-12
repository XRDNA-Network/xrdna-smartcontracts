// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../libraries/LibStorageSlots.sol';
import {IRegisteredEntity} from '../interfaces/entity/IRegisteredEntity.sol';
import {LibStringCase} from '../libraries/LibStringCase.sol';
import {VectorAddress, LibVectorAddress} from '../libraries/LibVectorAddress.sol';
import {ITermsOwner} from '../interfaces/registry/ITermsOwner.sol';
import {IAccessControl} from '../interfaces/IAccessControl.sol';
import {ChangeEntityTermsArgs} from '../interfaces/registry/IRemovableRegistry.sol';

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";



struct RegistrationTerms {
    uint16 coveragePeriodDays;
    uint16 gracePeriodDays;
    uint256 fee;
}

//when creating removable entities that also have vector addresses
struct RegistrationWithTermsAndVector {

    //the entity to register
    address entity;

    //the terms owner for the entity
    address termsOwner;

    //the terms for the entity
    RegistrationTerms terms;

    string name;

    //the vector address for the entity
    VectorAddress vector;
}

//when verifying that entity agrees to registration terms
struct TermsSignatureVerification {

    //owner of the entity
    address owner;

    //the terms authority for the entity
    address termsOwner;

    //the terms being applied to the entity
    RegistrationTerms terms;

    //signature expiration
    uint256 expiration;

    //entity owner's signature agreeing to terms
    bytes ownerTermsSignature;
}


//storage metadata for each registered entity
struct TermedRegistration {

    //the terms owner for the entity
    address owner;

    //the terms of the registration, if any
    RegistrationTerms terms;

    //the last time the terms were renewed
    uint256 lastRenewed;

    //if deactivated, the time to countdown the grace period
    uint256 deactivationTime;
}

//entity registration storage
struct RegistrationStorage {

    uint256 reentrancyLock;

    //removable entities
    mapping(address => TermedRegistration) removableRegistrations;

    //non-removable entities, which have no terms or deactivation state
    mapping(address => bool) staticRegistrations;

    //entities registered by their case-insensitive, globally-unique name, if applicable
    mapping(string => address) registrationsByName;
    
    //entities by their vector address, if applicable
    mapping(bytes32 => address) registrationsByVector; 
}

library LibRegistration {

    using LibStringCase for string;
    using MessageHashUtils for bytes;
    using LibVectorAddress for VectorAddress;

    uint256 public constant DAY = 1 days;

    modifier nonReentrant {
        RegistrationStorage storage rs = LibRegistration.load();
        require(rs.reentrancyLock == 0, "EntityRemovalExt: reentrant call");
        rs.reentrancyLock = 1;
        _;
        rs.reentrancyLock = 0;
    }

    function load() internal pure returns (RegistrationStorage storage ds) {
        bytes32 slot = LibStorageSlots.REGISTRATION_STORAGE;
        assembly {
            ds.slot := slot
        }
    }
    
    /**
     * @dev Checks if an entity is registered.
     */
    function isRegistered(address addr) public view returns (bool) {
        RegistrationStorage storage rs = load();
        //the more common case is that entities will be removable. So we check that first.
        bool isRemovable = address(rs.removableRegistrations[addr].owner) != address(0);
        if(isRemovable) {
            return true;
        }
        return rs.staticRegistrations[addr];
    }

    /**
     * @dev Gets the entity registered by a name, if applicable. Some entities, like assets, do not
     * have globally unique names so a zero-address would be returned in those cases.
     * 
     * NOTE: A case-insensitive comparison is used to find the entity by name. This only applies to
     * ascii based names and does not trim whitespace. Off-chain resources need to ensure that names
     * do not have hidden characters, etc.
     */
    function getEntityByName(string calldata nm) public view returns (address) {
        RegistrationStorage storage rs = load();
        return rs.registrationsByName[nm.lower()];
    }

    /**
     * @dev Gets the entity registered by a vector address, if applicable
     */
    function getEntityByVector(VectorAddress memory vector) public view returns (address) {
        RegistrationStorage storage rs = load();

        //has the vector address to use as a lookup key
        bytes32 hashed = keccak256(bytes(vector.asLookupKey()));
        return rs.registrationsByVector[hashed];
    }

    function removeVectorRegistration(VectorAddress memory vector) public {
        RegistrationStorage storage rs = load();
        bytes32 hashed = keccak256(bytes(vector.asLookupKey()));
        delete rs.registrationsByVector[hashed];
    }

    /**
     * @dev Registers a non-removable entity ignoring the name.
     */
    function registerNonRemovableEntityIgnoreName(address entity) public {
        RegistrationStorage storage rs = load();
        require(!rs.staticRegistrations[entity], "LibRegistration: entity already registered");
        rs.staticRegistrations[entity] = true;
    }

    /**
     * @dev Registers a non-removable entity. The name must be globally unique.
     */
    function registerNonRemovableEntity(address entity, string calldata name) public {
        RegistrationStorage storage rs = load();
        require(!rs.staticRegistrations[entity], "LibRegistration: entity already registered"); 
        string memory nm = name.lower();
        require(bytes(nm).length > 0, "LibRegistration: entity name is empty");
        require(rs.registrationsByName[nm] == address(0), "LibRegistration: entity name already registered");
        rs.registrationsByName[nm] = entity;
        
        rs.staticRegistrations[entity] = true;
    }

    /**
     * @dev Registers a removable entity. The name must be globally unique.
     */
    function registerRemovableEntity(address entity, address termsOwner, RegistrationTerms memory terms, string memory name) public {
        
        require(termsOwner != address(0), "LibRegistration: terms owner cannot be zero address");

        RegistrationStorage storage rs = load();

        //get the storage entry, or an empty one if doesn't exist yet.
        TermedRegistration storage reg = rs.removableRegistrations[entity];

        //make sure it doesn't exist yet
        require(address(reg.owner) == address(0), "LibRegistration: entity already registered");

        //make sure all removable entities, regardless of registration terms, are given sufficient
        //grace period to respsond to a deactivation.
        require(terms.gracePeriodDays > 0, "LibRegistration: grace period must be greater than 0");

        //make sure the entity has a globally unique name (barring any hidden or whitespace characters)
        string memory nm = name.lower();
        require(bytes(nm).length > 0, "LibRegistration: entity name is empty");
        require(rs.registrationsByName[nm] == address(0), "LibRegistration: entity name already registered");
        rs.registrationsByName[nm] = entity;
        
        //the terms owner has authority to reset terms or remove entities
        reg.owner = termsOwner;

        //the registration terms
        reg.terms = terms;

        //sets the registration start time to establish expiration
        reg.lastRenewed = block.timestamp;
    }

    /**
     * @dev Registers a removable entity ignoring the name.
     */
    function registerRemovableEntityIgnoreName(address entity, address termsOwner, RegistrationTerms memory terms) public {
        RegistrationStorage storage rs = load();
        TermedRegistration storage reg = rs.removableRegistrations[entity];
        require(address(reg.owner) == address(0), "LibRegistration: entity already registered");

        require(termsOwner != address(0), "LibRegistration: terms owner cannot be zero address");
        require(terms.gracePeriodDays > 0, "LibRegistration: grace period must be greater than 0");
        reg.owner = termsOwner;
        reg.terms = terms;
        reg.lastRenewed = block.timestamp;
    }

    /**
     * @dev Registers a removable entity with a vector address.
     */
    function registerRemovableVectoredEntity(RegistrationWithTermsAndVector memory args) public {
        registerRemovableEntity(args.entity, args.termsOwner, args.terms, args.name);
        if(bytes(args.vector.x).length > 0) {
            RegistrationStorage storage rs = load();
            string memory asKey = args.vector.asLookupKey();
            bytes32 hashed = keccak256(bytes(asKey));
            require(rs.registrationsByVector[hashed] == address(0), "RegistrationModule: vector already in use");
            rs.registrationsByVector[hashed] = args.entity;
        }
    }

    /**
     * @dev Registers a removable entity with a vector address, ignoring the name.
     */
    function registerRemovableVectoredEntityIgnoreName(RegistrationWithTermsAndVector memory args) public  {
        registerRemovableEntityIgnoreName(args.entity, args.termsOwner, args.terms);
        if(bytes(args.vector.x).length > 0) {
            RegistrationStorage storage rs = load();
            string memory asKey = args.vector.asLookupKey();
            bytes32 hashed = keccak256(bytes(asKey));
            require(rs.registrationsByVector[hashed] == address(0), "RegistrationModule: vector already in use");
            rs.registrationsByVector[hashed] = args.entity;
        }
    }

    /**
     * @dev Change the registration terms for an entity. This should be checked that the caller
     * is the authority for the entity. This checks that the entity agreed to the terms by
     * checking signature.
     */
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) public nonReentrant {
        RegistrationStorage storage rs = load();
        TermedRegistration storage reg = rs.removableRegistrations[args.entity];
        RegistrationTerms memory newTerms = _verifyEntitySignature(args);
        reg.terms = newTerms;

        //restart the coverage period clock with terms change
        reg.lastRenewed = block.timestamp;
    }

    /**
     * @dev Verify whether an entity owner agrees to new terms and fees.
     */
    function verifyNewEntityTermsSignature(TermsSignatureVerification memory args) public view {

        //make sure signature has not expired
        require(args.expiration > block.timestamp, "BaseRegistrationModule: expiration must be in the future");
        
        //hash terms plus the terms owner to ensure that the entity owner is agreeing to the terms AND the
        //the authority controlling those terms.
        bytes32 hash = keccak256(abi.encode(args.termsOwner, args.terms.fee, args.terms.coveragePeriodDays, args.terms.gracePeriodDays, args.expiration));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        address w = ECDSA.recover(sigHash, args.ownerTermsSignature);

        //note that we're checking the entity owner, not a signer. This is because this is a new 
        //entity and onlyl an owner is initially set.
        require(w == args.owner, "BaseRegistrationModule: entity owner signature verifying fees and terms owner is invalid");
    }

    /**
     * @dev Verifies that an entity owner agrees to new terms and fees.
     */
    function _verifyEntitySignature(ChangeEntityTermsArgs calldata args) internal view returns (RegistrationTerms memory) {
        require(args.expiration > block.timestamp, "BaseRegistrationModule: expiration must be in the future");
        RegistrationStorage storage rs = load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        ITermsOwner owner = ITermsOwner(tr.owner);

        //make sure terms owner is still active and can change terms
        require(owner.isStillActive(), "BaseRegistrationModule: entity terms owner is no longer active");
        RegistrationTerms memory newTerms = args.terms;

        //hash the new terms and terms owner authority
        bytes32 hash = keccak256(abi.encode(tr.owner, newTerms.fee, newTerms.coveragePeriodDays, newTerms.gracePeriodDays, args.expiration));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        address w = ECDSA.recover(sigHash, args.entitySignature);

        //the entity admin address must agree to changing terms
        require(IAccessControl(args.entity).isAdmin(w), "BaseRegistrationModule: entity signature invalid");
        return newTerms;
    }
}
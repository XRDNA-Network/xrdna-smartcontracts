// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;



import {
    IRegistration,  
    ChangeEntityTermsArgs,
    RegistrationWithTermsAndVector
} from "../interfaces/registry/IRegistration.sol";
import {RegistrationTerms} from "../libraries/LibTypes.sol";
import {LibStorageSlots} from '../libraries/LibStorageSlots.sol';
import {IRegisteredEntity} from '../interfaces/entity/IRegisteredEntity.sol';
import {LibStringCase} from '../libraries/LibStringCase.sol';
import {VectorAddress, LibVectorAddress} from '../libraries/LibVectorAddress.sol';
import {ITermsOwner} from '../interfaces/registry/ITermsOwner.sol';
import {IAccessControl} from '../interfaces/IAccessControl.sol';

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "hardhat/console.sol";

struct TermsSignatureVerification {
    address owner;
    address termsOwner;
    RegistrationTerms terms;
    uint256 expiration;
    bytes ownerTermsSignature;
}


struct TermedRegistration {
    address owner;
    RegistrationTerms terms;
    uint256 lastRenewed;
    uint256 deactivationTime;
}

struct RegistrationStorage {
    mapping(address => TermedRegistration) removableRegistrations;
    mapping(address => bool) staticRegistrations;
    mapping(string => address) registrationsByName;
    
    //not applicable to registrars or avatars
    mapping(bytes32 => address) registrationsByVector; 
}

library LibRegistration {

    using LibStringCase for string;
    using MessageHashUtils for bytes;
    using LibVectorAddress for VectorAddress;


    uint256 public constant DAY = 1 days;

    function load() internal pure returns (RegistrationStorage storage ds) {
        bytes32 slot = LibStorageSlots.REGISTRATION_STORAGE;
        assembly {
            ds.slot := slot
        }
    }
    
    function isRegistered(address addr) public view returns (bool) {
        RegistrationStorage storage rs = load();
        bool isStatic = rs.staticRegistrations[addr];
        if(isStatic) {
            return true;
        }
        return address(rs.removableRegistrations[addr].owner) != address(0);
    }

    function getEntityByName(string calldata nm) public view returns (address) {
        RegistrationStorage storage rs = load();
        return rs.registrationsByName[nm.lower()];
    }

    function getEntityByVector(VectorAddress memory vector) public view returns (address) {
        RegistrationStorage storage rs = load();
        bytes32 hashed = keccak256(bytes(vector.asLookupKey()));
        return rs.registrationsByVector[hashed];
    }
    
    function registerEntityNoRemoval(RegistrationWithTermsAndVector memory args) public {
        address a = args.entity;
        require(a != address(0), "LibRegistration: entity creation failed");
        IRegisteredEntity entity = IRegisteredEntity(a);
        RegistrationStorage storage rs = load();
        require(rs.staticRegistrations[a] == false, "RegistrationExt: entity already registered");
        string memory nm = entity.name().lower();
        require(bytes(nm).length > 0, "RegistrationExt: entity name is empty");
        require(rs.registrationsByName[nm] == address(0), "RegistrationExt: entity name already registered");
        rs.registrationsByName[nm] = a;
        rs.staticRegistrations[a] = true;

        if(bytes(args.vector.x).length > 0) {
            string memory asKey = args.vector.asLookupKey();
            bytes32 hashed = keccak256(bytes(asKey));
            require(rs.registrationsByVector[hashed] == address(0), "RegistrationExt: vector already in use");
            rs.registrationsByVector[hashed] = a;
        }
    }

    function registerEntityWithRemoval(RegistrationWithTermsAndVector memory args) public  {
        address a = args.entity;
        require(a != address(0), "RegistrationExt: entity creation failed");
        require(args.terms.gracePeriodDays > 0, "RegistrationExt: grace period must be greater than 0");
        IRegisteredEntity entity = IRegisteredEntity(a);
        RegistrationStorage storage rs = load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];
        string memory nm = entity.name().lower();
        require(bytes(nm).length > 0, "RegistrationExt: entity name is empty");
        require(rs.registrationsByName[nm] == address(0), "RegistrationModule: entity name already registered");
        require(address(reg.owner) == address(0), "RegistrationModule: entity already registered with different name??");
        RegistrationTerms memory terms = RegistrationTerms({
            coveragePeriodDays: args.terms.coveragePeriodDays,
            gracePeriodDays: args.terms.gracePeriodDays,
            fee: args.terms.fee
        });
        reg.owner = msg.sender;
        reg.terms = terms;
        reg.lastRenewed = block.timestamp;
        rs.registrationsByName[nm] = address(entity);
        if(bytes(args.vector.x).length > 0) {
            string memory asKey = args.vector.asLookupKey();
            bytes32 hashed = keccak256(bytes(asKey));
            require(rs.registrationsByVector[hashed] == address(0), "RegistrationModule: vector already in use");
            rs.registrationsByVector[hashed] = a;
        }
    }

    function changeEntityTerms(ChangeEntityTermsArgs calldata args) public {
        RegistrationStorage storage rs = load();
        TermedRegistration storage reg = rs.removableRegistrations[args.entity];
        require(reg.owner == msg.sender, "RegistrationModule: sender is not the terms owner for the entity");
        require(ITermsOwner(msg.sender).isStillActive(), "RegistrationModule: entity terms owner is no longer active");
        RegistrationTerms memory newTerms = _verifyEntitySignature(args);
        reg.terms = newTerms;
        reg.lastRenewed = block.timestamp;
    }

    function verifyNewEntityTermsSignature(TermsSignatureVerification memory args) public view {
        require(args.expiration > block.timestamp, "BaseRegistrationModule: expiration must be in the future");
        bytes32 hash = keccak256(abi.encode(args.termsOwner, args.terms.fee, args.terms.coveragePeriodDays, args.terms.gracePeriodDays, args.expiration));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        address w = ECDSA.recover(sigHash, args.ownerTermsSignature);
        require(w == args.owner, "BaseRegistrationModule: entity owner signature verifying fees and terms owner is invalid");
    }

    function _verifyEntitySignature(ChangeEntityTermsArgs calldata args) internal view returns (RegistrationTerms memory) {
        require(args.expiration > block.timestamp, "BaseRegistrationModule: expiration must be in the future");
        RegistrationStorage storage rs = load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        ITermsOwner owner = ITermsOwner(tr.owner);
        require(owner.isStillActive(), "BaseRegistrationModule: entity terms owner is no longer active");
        RegistrationTerms memory newTerms = args.terms;
        bytes32 hash = keccak256(abi.encode(newTerms.fee, newTerms.coveragePeriodDays, newTerms.gracePeriodDays, args.expiration));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        address w = ECDSA.recover(sigHash, args.entitySignature);
        require(IAccessControl(args.entity).isSigner(w), "BaseRegistrationModule: entity signature invalid");
        return newTerms;
    }
}
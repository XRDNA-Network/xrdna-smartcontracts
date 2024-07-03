// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistration, 
        RegistrationTerms,
        ChangeEntityTermsArgs
} from "./IRegistration.sol";
import {IModuleRegistry} from '../../core/IModuleRegistry.sol';
import {RegistrationStorage, TermedRegistration, LibRegistrationStorage} from './LibRegistrationStorage.sol';
import {IRegisteredEntity} from './IRegisteredEntity.sol';
import {LibStringCase} from '../../libraries/LibStringCase.sol';
import {ModuleVersion} from '../IModule.sol';
import {ITermsOwner} from './ITermsOwner.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "hardhat/console.sol";

/**
    * @title BaseRegistrationModule
    * @dev A module for registering entities in a registry. Entities can be registered with or without terms and conditions.
    * WARNING: This module assumes that the delegatecalling contract has made the necessary access checks and status checks
    * prior to delegate calling this module.
 */
contract RegistrationModule is IRegistration {

    using LibStringCase for string;
    using MessageHashUtils for bytes;


    uint256 public constant DAY = 1 days;
    string public constant override name = "IRegistration";

    function version() public view virtual override returns (ModuleVersion memory) {
        return ModuleVersion(1, 0);
    }

    function isRegistered(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        bool isStatic = rs.staticRegistrations[addr];
        if(isStatic) {
            return true;
        }
        return address(rs.removableRegistrations[addr].owner) != address(0);
    }

    function getEntityByName(string calldata nm) public view returns (address) {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        return rs.registrationsByName[nm.lower()];
    }
    
    function registerEntityNoTermsNoRemoval(address a) public {

        require(a != address(0), "BaseRegistrationModule: entity creation failed");
        IRegisteredEntity entity = IRegisteredEntity(a);
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        require(rs.staticRegistrations[a] == false, "RegistrationExt: entity already registered");
        string memory nm = entity.name().lower();
        require(rs.registrationsByName[nm] == address(0), "RegistrationExt: entity name already registered");
        rs.registrationsByName[nm] = a;
        rs.staticRegistrations[a] = true;
        /*
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(a).transfer(msg.value);
            }
        }
        */
    }

    function registerEntityNoTermsWithRemoval(address a, uint16 gracePeriodDays) public  {
        require(a != address(0), "RegistrationExt: entity creation failed");
        IRegisteredEntity entity = IRegisteredEntity(a);
        _basicTermedRegistration(entity, RegistrationTerms(0, 0, gracePeriodDays));
        /*
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(address(entity)).transfer(msg.value);
            }
        }
        */
    }

    function registerEntityWithTerms(address a, RegistrationTerms calldata terms) public  {
        console.log("registerEntityWithTerms");
        require(a != address(0), "RegistrationExt: entity creation failed");
        IRegisteredEntity entity = IRegisteredEntity(a);
        _basicTermedRegistration(entity, terms);
        /*
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(address(entity)).transfer(msg.value);
            }
        }
        */
    }

    function changeEntityTerms(ChangeEntityTermsArgs calldata args) public {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage reg = rs.removableRegistrations[args.entity];
        require(reg.owner == msg.sender, "RegistrationModule: sender is not the owner of the entity");
        RegistrationTerms memory newTerms = _verifyEntitySignature(args);
        reg.terms = newTerms;
        reg.lastRenewed = block.timestamp;
    }

    function _basicTermedRegistration(IRegisteredEntity entity, RegistrationTerms memory terms) internal {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];
        string memory nm = entity.name().lower();
        require(rs.registrationsByName[nm] == address(0), "RegistrationModule: entity name already registered");
        require(address(reg.owner) == address(0), "RegistrationModule: entity already registered with different name??");
        reg.owner = msg.sender;
        reg.terms = terms;
        reg.lastRenewed = block.timestamp;
        rs.registrationsByName[nm] = address(entity);
        
    }

    function _verifyEntitySignature(ChangeEntityTermsArgs calldata args) internal view returns (RegistrationTerms memory) {
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        ITermsOwner owner = ITermsOwner(tr.owner);
        RegistrationTerms memory newTerms = owner.getTerms();
        bytes32 hash = keccak256(abi.encode(newTerms.fee, newTerms.coveragePeriodDays, newTerms.gracePeriodDays, args.expiration));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        //make sure signer is a signer for the destination experience's company
        bytes32 sigHash = b.toEthSignedMessageHash();
        address w = ECDSA.recover(sigHash, args.entitySignature);
        require(IRegisteredEntity(args.entity).isSigner(w), "BaseRegistrationModule: entity signature invalid");
        return newTerms;
    }
}
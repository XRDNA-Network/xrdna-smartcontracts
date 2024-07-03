// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IControlChange, ChangeControllerArgsNoTerms, ChangeControllerArgsWithTerms} from './IControlChange.sol';
import {IModuleRegistry} from '../../core/IModuleRegistry.sol';
import {ModuleVersion} from '../IModule.sol';
import {TermedRegistration, RegistrationStorage, LibRegistrationStorage} from '../registration/LibRegistrationStorage.sol';
import {ITermsOwner} from '../registration/ITermsOwner.sol';
import {IRegisteredEntity} from '../registration/IRegisteredEntity.sol';

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


contract ControlChangeModule is IControlChange {

    using MessageHashUtils for bytes;

    uint256 public constant DAY = 1 days;
    string public constant name = "IControlChange";

    function version() public pure override returns (ModuleVersion memory) {
        return ModuleVersion(1, 0);
    }

    /**
     * @dev Change the controller that can activate/deactivate/remove the entity. There are no terms set when the 
     * controller is changed with this function. Both the previous controller and the entity must sign the change
     * which includes the entity address, new controller address and the expiration time. No nonce is required since the expiration
     * time is used to prevent replay attacks. This must be called by the new controller contract.
     */
    function changeControllerNoTerms(ChangeControllerArgsNoTerms calldata args) 
    external   {
        _verifyMigrationSigsNoTerms(args);
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        tr.owner =msg.sender;
        tr.lastRenewed = block.timestamp;
        //restart timer for new registrar to reactivate entity if necessary
        tr.deactivationTime = 0;
        emit ControllerChanged(args.entity, msg.sender);
    }

    /**
     * @dev Change the controller that can activate/deactivate/remove the entity. The new controller can set terms 
     * for the entity. The initial terms are provided and signed by the entity, but not previous controller. The
     * previous controller only signs the entity address, new controller address, expiration time. The entity must 
     * sign the new controller address, terms, and expiration time. No nonce is required since the expiration
     * time is used to prevent replay attacks. This must be called by the new controller contract.
     */
    function changeControllerWithTerms(ChangeControllerArgsWithTerms calldata args) 
    external  {

        _verifyMigrationSigsWithTerms(args);
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        tr.owner = msg.sender;
        tr.terms = args.terms;
        tr.lastRenewed = block.timestamp;
        tr.deactivationTime = 0;
        emit ControllerChanged(args.entity, msg.sender);
    }

    function _verifyMigrationSigsNoTerms(ChangeControllerArgsNoTerms calldata args) internal view {
        require(args.expiration > block.timestamp, "Registrar: migration signature expired");

        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        ITermsOwner owner = ITermsOwner(tr.owner);
        bytes32 hash = keccak256(abi.encode(args.entity, msg.sender, args.expiration));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        //make sure signer is a signer for the destination experience's company
        bytes32 sigHash = b.toEthSignedMessageHash();
        
        if(args.oldControllerSignature.length == 0) {
            require(!owner.isStillActive(), "Registrar: current registrar is active but no signature provided");
        } else {
            address r = ECDSA.recover(sigHash, args.oldControllerSignature);
            require(owner.isTermsOwnerSigner(r), "Registrar: current registrar signature invalid");
        }
        address w = ECDSA.recover(sigHash, args.entitySignature);
        require(IRegisteredEntity(args.entity).isSigner(w), "Registrar: entity signature invalid");
    }

    function _verifyMigrationSigsWithTerms(ChangeControllerArgsWithTerms calldata args) internal view {
        require(args.expiration > block.timestamp, "Registrar: migration signature expired");
        RegistrationStorage storage rs = LibRegistrationStorage.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        ITermsOwner owner = ITermsOwner(tr.owner);
        bytes32 hash = keccak256(abi.encode(args.entity, msg.sender, args.expiration, args.terms.fee, args.terms.coveragePeriodDays, args.terms.gracePeriodDays));
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
        require(IRegisteredEntity(args.entity).isSigner(w), "Registrar: entity signature invalid");
    }
}

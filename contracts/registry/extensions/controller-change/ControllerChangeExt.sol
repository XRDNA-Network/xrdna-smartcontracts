// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtension} from "../../../core/extensions/BaseExtension.sol";
import {ExtensionMetadata} from '../../../core/extensions/IExtension.sol';
import {TermedRegistration,RegistrationStorage, LibRegistration } from '../../libraries/LibRegistration.sol';
import {AddSelectorArgs, SelectorArgs, LibExtensions} from '../../../core/LibExtensions.sol';
import {LibAccess} from '../../../core/LibAccess.sol';
import {ITermsOwner} from '../../../entity/extensions/terms-owner/interfaces/ITermsOwner.sol';
import {ChangeControllerArgsNoTerms, ChangeControllerArgsWithTerms, IControllerChangeExtension} from './interfaces/IControllerChangeExtension.sol';
import {IRegistry} from '../../interfaces/IRegistry.sol';
import {IRegisteredEntity} from '../../../entity/interfaces/IRegisteredEntity.sol';
import {ITermsOwner} from '../../../entity/extensions/terms-owner/interfaces/ITermsOwner.sol';

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


contract ControllerChangeExt is BaseExtension, IControllerChangeExtension {

    using MessageHashUtils for bytes;

    uint256 public constant DAY = 1 days;

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.core.registration.ControllerChangeExt", 1);
    }

    modifier onlyRegisteredEntity(address entity) {
        RegistrationStorage storage rs = LibRegistration.load();
        require(address(rs.removableRegistrations[entity].owner)!= address(0), "Registrar: entity not registered");
        _;
    }
    
    modifier onlyActiveTermsOwner() {
        //this forces shell to have implemented this function
        require(IRegistry(address(this)).isActiveTermsOwner(msg.sender), "ControllerChangesExt: caller is not an active terms owner");
        _;
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorArgs[] memory args = new SelectorArgs[](2);
        args[0] = SelectorArgs({
            selector: this.changeControllerNoTerms.selector,
            isVirtual: false
        });
        args[1] = SelectorArgs({
            selector: this.changeControllerWithTerms.selector,
            isVirtual: false
        });
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            selectors: args,
            impl: myAddress
        }));
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress, uint256 currentVersion) external {
        //no-op
    }

    /**
     * @dev Change the controller that can activate/deactivate/remove the entity. There are no terms set when the 
     * controller is changed with this function. Both the previous controller and the entity must sign the change
     * which includes the entity address, new controller address and the expiration time. No nonce is required since the expiration
     * time is used to prevent replay attacks. This must be called by the new controller contract.
     */
    function changeControllerNoTerms(ChangeControllerArgsNoTerms calldata args) 
    external onlyRegisteredEntity(args.entity) onlyActiveTermsOwner {
        _verifyMigrationSigsNoTerms(args);
        RegistrationStorage storage rs = LibRegistration.load();
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
    external onlyRegisteredEntity(args.entity) onlyActiveTermsOwner{

        _verifyMigrationSigsWithTerms(args);
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage tr = rs.removableRegistrations[args.entity];
        tr.owner = msg.sender;
        tr.terms = args.terms;
        tr.lastRenewed = block.timestamp;
        tr.deactivationTime = 0;
        emit ControllerChanged(args.entity, msg.sender);
    }

    function _verifyMigrationSigsNoTerms(ChangeControllerArgsNoTerms calldata args) internal view {
        require(args.expiration > block.timestamp, "Registrar: migration signature expired");

        RegistrationStorage storage rs = LibRegistration.load();
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
            require(owner.isSigner(r), "Registrar: current registrar signature invalid");
        }
        address w = ECDSA.recover(sigHash, args.entitySignature);
        require(IRegisteredEntity(args.entity).isSigner(w), "Registrar: entity signature invalid");
    }

    function _verifyMigrationSigsWithTerms(ChangeControllerArgsWithTerms calldata args) internal view {
        require(args.expiration > block.timestamp, "Registrar: migration signature expired");
        RegistrationStorage storage rs = LibRegistration.load();
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
            require(owner.isSigner(r), "Registrar: current registrar signature invalid");
        }
        address no = ECDSA.recover(sigHash, args.entitySignature);
        require(ITermsOwner(msg.sender).isSigner(no), "Registrar: new controller signature invalid");
        address w = ECDSA.recover(sigHash, args.entitySignature);
        require(IRegisteredEntity(args.entity).isSigner(w), "Registrar: entity signature invalid");
    }
}

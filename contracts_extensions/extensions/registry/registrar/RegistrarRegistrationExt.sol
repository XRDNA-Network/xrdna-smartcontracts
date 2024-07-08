// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistrationExt} from '../BaseRegistrationExt.sol';
import {ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {CreateEntityArgs, RegistrationWithTermsAndVector} from '../../../interfaces/registry/IRegistration.sol';
import {VectorAddress} from '../../../libraries/LibVectorAddress.sol';
import {LibRegistration, TermsSignatureVerification} from '../../../libraries/LibRegistration.sol';
import {CommonInitArgs, IRegisteredEntity} from '../../../interfaces/entity/IRegisteredEntity.sol';
import {LibFactory, FactoryStorage} from '../../../libraries/LibFactory.sol';
import {LibClone} from '../../../libraries/LibClone.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';

contract RegistrarRegistrationExt is BaseRegistrationExt {


    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.REGISTRAR_REGISTRATION,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory selectors = new SelectorInfo[](5);

        selectors[0] = SelectorInfo({
            selector: super.getEntityByName.selector,
            name: "getEntityByName(string)"
        });
        selectors[1] = SelectorInfo({
            selector: super.changeEntityTerms.selector,
            name: "changeEntityTerms(address,RegistrationTerms)"
        });
        selectors[2] = SelectorInfo({
            selector: super.isRegistered.selector,
            name: "isRegistered(address)"
        });
        selectors[3] = SelectorInfo({
            selector: this.createRegistrarNoRemoval.selector,
            name: "createRegistrarNoRemoval(CreateEntityArgs)"
        });
        selectors[4] = SelectorInfo({
            selector: this.createRemovableRegistrar.selector,
            name: "createRemovableRegistrar(CreateEntityArgs)"
        });
       
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: selectors
        }));
    }


    function register() external onlyRegisteredEntity {
        //no-op
    }



    /**
     * @dev Create and register a new entity with the given arguments.
     */
    function createRegistrarNoRemoval(CreateEntityArgs calldata args) external payable onlyAdmin returns (address) {
        
        require(args.terms.gracePeriodDays == 0, "RegistrarRegistrationExt: grace period not allowed for non-removable registration");
        require(args.terms.coveragePeriodDays == 0, "RegistrarRegistrationExt: coverage period not allowed for non-removable registration");
        require(args.terms.fee == 0, "RegistrarRegistrationExt: fee not allowed for non-removable registration");
        
        VectorAddress memory v = VectorAddress({
            x: "",
            y: "",
            z: "",
            t: 0,
            p: 0,
            p_sub: 0
        });


        FactoryStorage storage fs = LibFactory.load();
        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "RegistrarRegistration: entity cloning failed");

        CommonInitArgs memory initArgs = CommonInitArgs({
            owner: args.owner,
            name: args.name,
            termsOwner: address(this),
            registry: address(this),
            initData: args.initData,
            vector: v
        });

        IRegisteredEntity(entity).init(initArgs);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: entity,
            terms: args.terms,
            vector: v
        });
        LibRegistration.registerEntityNoRemoval(regArgs);
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

    function createRemovableRegistrar(CreateEntityArgs calldata args) public payable onlyAdmin returns (address) {
        require(args.terms.gracePeriodDays > 0, "RegistrarRegistrationExt: grace period required for removable registration");

        TermsSignatureVerification memory verification = TermsSignatureVerification({
            terms: args.terms,
            termsOwner: address(this),
            owner: args.owner,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);

        VectorAddress memory v = VectorAddress({
            x: "",
            y: "",
            z: "",
            t: 0,
            p: 0,
            p_sub: 0
        });

        FactoryStorage storage fs = LibFactory.load();
        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "RegistrarRegistration: entity cloning failed");

        CommonInitArgs memory initArgs = CommonInitArgs({
            owner: args.owner,
            name: args.name,
            termsOwner: address(this),
            registry: address(this),
            initData: args.initData,
            vector: v
        });

        IRegisteredEntity(entity).init(initArgs);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: entity,
            terms: args.terms,
            vector: v
        });
        LibRegistration.registerEntityWithRemoval(regArgs);
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
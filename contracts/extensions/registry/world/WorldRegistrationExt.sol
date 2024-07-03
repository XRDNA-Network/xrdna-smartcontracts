// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistrationExt} from '../BaseRegistrationExt.sol';
import {ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {RegistrationWithTermsAndVector} from '../../../interfaces/registry/IRegistration.sol';
import {VectorAddress, LibVectorAddress} from '../../../libraries/LibVectorAddress.sol';
import {LibRegistration, TermsSignatureVerification} from '../../../libraries/LibRegistration.sol';
import {CommonInitArgs, IRegisteredEntity} from '../../../interfaces/entity/IRegisteredEntity.sol';
import {ITermsOwner} from '../../../interfaces/registry/ITermsOwner.sol';
import {LibFactory, FactoryStorage} from '../../../libraries/LibFactory.sol';
import {LibClone} from '../../../libraries/LibClone.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {IRegistration} from '../../../interfaces/registry/IRegistration.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';
import {IRegistrarRegistry} from '../../../registrar/registry/IRegistrarRegistry.sol';
import {CreateWorldArgs} from '../../../world/registry/IWorldRegistry.sol';

contract WorldRegistrationExt is BaseRegistrationExt {

    using LibVectorAddress for VectorAddress;

    modifier onlyActiveRegistrar {
        require(IRegistrarRegistry(IWorldRegistry(address(this)).registrarRegistry()).isRegistered(msg.sender), "WorldRegistrationExt: caller is not a registered registrar");
        require(ITermsOwner(msg.sender).isStillActive(), "WorldRegistration: registrar is not active");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.WORLD_REGISTRATION,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory selectors = new SelectorInfo[](4);
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
            selector: this.createWorld.selector,
            name: "createWorld(CreateEntityArgs)"
        });

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: selectors
        }));
    }


    function register() external onlyRegisteredEntity {
        //no-op
    }

    function createWorld(CreateWorldArgs calldata args) public payable onlyActiveRegistrar returns (address) {
        require(args.terms.gracePeriodDays > 0, "WorldRegistrationExt: grace period required for removable registration");
        
        //false, false means no p value or pSub value in vector
        args.vector.validate(false, false);

        TermsSignatureVerification memory verification = TermsSignatureVerification({
            terms: args.terms,
            termsOwner: msg.sender,
            owner: args.owner,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);

        FactoryStorage storage fs = LibFactory.load();
        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "WorldRegistration: entity cloning failed");

        CommonInitArgs memory initArgs = CommonInitArgs({
            owner: args.owner,
            name: args.name,
            termsOwner: msg.sender,
            registry: address(this),
            initData: args.initData,
            vector: args.vector
        });

        IRegisteredEntity(entity).init(initArgs);
        RegistrationWithTermsAndVector memory regArgs = RegistrationWithTermsAndVector({
            entity: entity,
            terms: args.terms,
            vector: args.vector
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
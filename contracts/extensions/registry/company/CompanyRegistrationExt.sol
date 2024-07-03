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
import {IWorld} from '../../../world/instance/IWorld.sol';
import {ICompanyRegistry, CreateCompanyArgs} from '../../../company/registry/ICompanyRegistry.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';

contract CompanyRegistrationExt is BaseRegistrationExt {

    modifier onlyActiveWorld {
        address wr = ICompanyRegistry(address(this)).worldRegistry();
        require(wr != address(0), "CompanyRegistrationExt: world registry not set");
        IWorldRegistry reg = IWorldRegistry(wr);
        IWorld world = IWorld(msg.sender);
        require(world.isEntityActive(), "CompanyRegistrationExt: world is not active");
        require(reg.isRegistered(msg.sender), "CompanyRegistrationExt: world is not registered");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.COMPANY_REGISTRATION,
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
            selector: this.createCompany.selector,
            name: "createCompany(CreateCompanyArgs)"
        });
        selectors[4] = SelectorInfo({
            selector: super.getEntityByVector.selector,
            name: "getEntityByVector(VectorAddress)"
        });
       
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: selectors
        }));
    }


    function register() external onlyRegisteredEntity {
        //no-op
    }


    function createCompany(CreateCompanyArgs calldata args) public payable onlyActiveWorld returns (address) {
        require(args.terms.gracePeriodDays > 0, "RegistrarRegistrationExt: grace period required for removable registration");

        TermsSignatureVerification memory verification = TermsSignatureVerification({
            terms: args.terms,
            termsOwner: msg.sender,
            owner: args.owner,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);
        VectorAddress memory v = args.vector;
        require(v.p > 0, "CompanyRegistration: vector address p value must be greater than 0 for company");
        require(v.p_sub == 0, "CompanyRegistration: vector address p_sub must be 0 for company");

        FactoryStorage storage fs = LibFactory.load();
        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "CompanyRegistration: entity cloning failed");

        CommonInitArgs memory initArgs = CommonInitArgs({
            owner: args.owner,
            name: args.name,
            termsOwner: msg.sender,
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
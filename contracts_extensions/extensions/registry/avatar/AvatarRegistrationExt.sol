// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistrationExt} from '../BaseRegistrationExt.sol';
import {ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {CreateEntityArgs, RegistrationWithTermsAndVector} from '../../../interfaces/registry/IRegistration.sol';
import {VectorAddress, LibVectorAddress} from '../../../libraries/LibVectorAddress.sol';
import {LibRegistration, TermsSignatureVerification} from '../../../libraries/LibRegistration.sol';
import {CommonInitArgs, IRegisteredEntity} from '../../../interfaces/entity/IRegisteredEntity.sol';
import {LibFactory, FactoryStorage} from '../../../libraries/LibFactory.sol';
import {LibClone} from '../../../libraries/LibClone.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {IWorld} from '../../../world/instance/IWorld.sol';
import {IAvatarRegistry, CreateAvatarArgs} from '../../../avatar/registry/IAvatarRegistry.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';
import {RegistrationTerms} from '../../../libraries/LibTypes.sol';

contract AvatarRegistrationExt is BaseRegistrationExt {

    using LibVectorAddress for VectorAddress;

    modifier onlyActiveWorld {
        address wr = IAvatarRegistry(address(this)).worldRegistry();
        require(wr != address(0), "AvatarRegistrationExt: world registry not set");
        IWorldRegistry reg = IWorldRegistry(wr);
        IWorld world = IWorld(msg.sender);
        require(world.isEntityActive(), "AvatarRegistrationExt: world is not active");
        require(reg.isRegistered(msg.sender), "AvatarRegistrationExt: world is not registered");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.AVATAR_REGISTRATION,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory selectors = new SelectorInfo[](3);

        selectors[0] = SelectorInfo({
            selector: super.getEntityByName.selector,
            name: "getEntityByName(string)"
        });
        selectors[1] = SelectorInfo({
            selector: super.isRegistered.selector,
            name: "isRegistered(address)"
        });
        selectors[2] = SelectorInfo({
            selector: this.createAvatar.selector,
            name: "createAvatar(CreateAvatarArgs)"
        });
       
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: selectors
        }));
    }


    function register() external onlyRegisteredEntity {
        //no-op
    }


    function createAvatar(CreateAvatarArgs calldata args) public payable onlyActiveWorld returns (address) {
       
        FactoryStorage storage fs = LibFactory.load();
        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "AvatarRegistration: entity cloning failed");

        //dummy location. Avatar will get this from its default experience
        VectorAddress memory v = VectorAddress({
            x: "",
            y: "",
            z: "",
            t: 0,
            p: 1,
            p_sub: 1
        });

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
            terms: RegistrationTerms({
                fee: 0,
                coveragePeriodDays: 0,
                gracePeriodDays: 30
            }),
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

}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibFactory} from '../../libraries/LibFactory.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {IWorldAddAvatar, NewAvatarArgs} from '../../interfaces/world/IWorldAddAvatar.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {IAvatarRegistry, CreateAvatarArgs} from '../../avatar/registry/IAvatarRegistry.sol';
import {LibWorld, WorldStorage} from '../../world/instance/LibWorld.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

contract WorldAddAvatarExt is IExtension, IWorldAddAvatar {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "WorldAddAvatarExt: restricted to admins");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "WorldAddAvatarExt: restricted to signers");
        _;
    }
     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.WORLD_ADD_AVATAR,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](1);

        sigs[0] = SelectorInfo({
            selector: this.registerAvatar.selector,
            name: "registerAvatar(NewAvatarArgs)"
        });
       
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no-op
    }

    /**
     * Initialize any storage related to the extension
     */
    function initStorage(ExtensionInitArgs calldata args) external {
        //nothing to initialize
    }

    /**
     * @dev Registers a new avatar contract. Must be called by a world signer
     */
    function registerAvatar(NewAvatarArgs memory args) external payable onlySigner returns (address avatar) {
        address a = IWorld(address(this)).avatarRegistry();
        require(a != address(0), "WorldAddAvatarExt: company registry not set");
        IAvatarRegistry avatarRegistry = IAvatarRegistry(a); 
        avatar = avatarRegistry.createAvatar(CreateAvatarArgs({
            sendTokensToOwner: args.sendTokensToOwner,
            owner: args.owner,
            name: args.name,
            initData: args.initData
        }));

        emit IWorld.WorldAddedAvatar(avatar, args.owner);

    }

}
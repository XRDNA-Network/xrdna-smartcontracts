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
import {IRegistrarWorldRegistration, NewWorldArgs} from '../../interfaces/registrar/IRegistrarWorldRegistration.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {CreateWorldArgs} from '../../world/registry/IWorldRegistry.sol';

contract RegistrarWorldRegistrationExt is IExtension, IRegistrarWorldRegistration {



    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "FactoryExt: restricted to admins");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "FactoryExt: restricted to signers");
        _;
    }
     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.REGISTRAR_WORLD_REGISTRATION,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](4);

        sigs[0] = SelectorInfo({
            selector: this.registerWorld.selector,
            name: "registerWorld(NewWorldArgs)"
        });
        sigs[1] = SelectorInfo({
            selector: this.deactivateWorld.selector,
            name: "deactivateWorld(address,string)"
        });
        sigs[2] = SelectorInfo({
            selector: this.reactivateWorld.selector,
            name: "reactivateWorld(address)"
        });
        sigs[3] = SelectorInfo({
            selector: this.removeWorld.selector,
            name: "removeWorld(address,string)"
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
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(NewWorldArgs memory args) external payable onlySigner returns (address world) {
        IWorldRegistry worldRegistry = IWorldRegistry(IRegistrar(address(this)).worldRegistry());
        return worldRegistry.createWorld(CreateWorldArgs({
            sendTokensToOwner: args.sendTokensToOwner,
            owner: args.owner,
            name: args.name,
            terms: args.terms,
            initData: args.initData,
            ownerTermsSignature: args.ownerTermsSignature,
            expiration: args.expiration,
            vector: args.baseVector
        }));
    }

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world, string calldata reason) external onlySigner {
        IWorldRegistry worldRegistry = IWorldRegistry(IRegistrar(address(this)).worldRegistry());
        worldRegistry.deactivateEntity(IRemovableEntity(world), reason);
    }

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external onlySigner {
        IWorldRegistry worldRegistry = IWorldRegistry(IRegistrar(address(this)).worldRegistry());
        worldRegistry.reactivateEntity(IRemovableEntity(world));
    }

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world, string calldata reason) external onlySigner {
        IWorldRegistry worldRegistry = IWorldRegistry(IRegistrar(address(this)).worldRegistry());
        worldRegistry.removeEntity(IRemovableEntity(world), reason);
    }

}
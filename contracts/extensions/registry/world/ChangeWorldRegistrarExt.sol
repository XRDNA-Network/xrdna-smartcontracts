// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IRemovableEntity} from '../../../interfaces/entity/IRemovableEntity.sol';
import {LibAccess} from '../../../libraries/LibAccess.sol';
import {LibEntityRemoval} from '../../../libraries/LibEntityRemoval.sol';
import {IExtension, ExtensionInitArgs, ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {IRegistrarRegistry} from '../../../registrar/registry/IRegistrarRegistry.sol';
import {ITermsOwner} from '../../../interfaces/registry/ITermsOwner.sol';
import {IControlChange, ChangeControllerArgs} from '../../../interfaces/registry/IControlChange.sol';
import {LibControlChange} from '../../../libraries/LibControlChange.sol';
import {IWorldRegistry} from '../../../world/registry/IWorldRegistry.sol';
import {IRegistrarRegistry} from '../../../registrar/registry/IRegistrarRegistry.sol';

contract ChangeWorldRegistrarExt is IExtension, IControlChange {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "WorldRemovalExt: restricted to admins");
        _;
    }

    modifier onlyActiveRegistrar(IRemovableEntity entity) {
        require(IRegistrarRegistry(IWorldRegistry(address(this)).registrarRegistry()).isRegistered(msg.sender), "WorldRegistrationExt: caller is not a registered registrar");
        require(ITermsOwner(msg.sender).isStillActive(), "WorldRegistration: registrar is not active");
        require(entity.termsOwner() == msg.sender, "WorldRegistrationExt: caller is not the entity's terms owner");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.CHANGE_REGISTRAR,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](1);
        sigs[0] = SelectorInfo({
            selector: this.changeController.selector,
            name: "changeController(ChangeControllerArgs)"
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

    function changeController(ChangeControllerArgs calldata args) external onlyActiveRegistrar(IRemovableEntity(args.entity)) {
        LibControlChange.changeControllerWithTerms(args);
    }
}
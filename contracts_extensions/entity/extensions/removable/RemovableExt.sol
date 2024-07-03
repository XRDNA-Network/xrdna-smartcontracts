// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtension} from '../../../core/extensions/BaseExtension.sol';
import {ExtensionMetadata} from '../../../core/extensions/IExtension.sol';
import {IRemovable} from './interfaces/IRemovable.sol';
import {IRemovableExtension} from './interfaces/IRemovableExtension.sol';
import {EntityStorage, LibEntity} from '../../libraries/LibEntity.sol';
import {AddSelectorArgs, SelectorArgs, LibExtensions} from '../../../core/LibExtensions.sol';

contract RemovableExt is BaseExtension, IRemovableExtension {

    modifier onlyRegistry() {
        // This is a placeholder function that should be overridden by the entity the extension is installed in
        require(isYourRegistry(msg.sender), "RemovableExt: caller is not the registry responsible for this entity");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.entity.RemovableExt", 1);
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) public virtual {
        SelectorArgs[] memory selectors = new SelectorArgs[](6);
        selectors[0] = SelectorArgs({
            selector: this.deactivate.selector,
            isVirtual: false
        });
        selectors[1] = SelectorArgs({
            selector: this.reactivate.selector,
            isVirtual: false
        });
        selectors[2] = SelectorArgs({
            selector: this.remove.selector,
            isVirtual: false
        });
        selectors[3] = SelectorArgs({
            selector: this.isRemoved.selector,
            isVirtual: false
        });
        selectors[4] = SelectorArgs({
            selector: this.isEntityActive.selector,
            isVirtual: false
        });
        selectors[5] = SelectorArgs({
            selector: this.isYourRegistry.selector,
            isVirtual: true
        });
        AddSelectorArgs memory args = AddSelectorArgs({
            selectors: selectors,
            impl: myAddress
        });
        LibExtensions.addExtensionSelectors(args);
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress, uint256 currentVersion) public {
        //no-op
    }

    function initStorage(address, string calldata _name, uint256 _version, bytes calldata) external override {
        //no-op
    }

    function isYourRegistry(address) public pure virtual returns (bool) {
        revert("RemovableExt: isYourRegistry not implemented");
    }

    function deactivate(string memory reason) external onlyRegistry {
        LibEntity.load().active = false;
        emit Deactivated(msg.sender, reason);
    }

    function reactivate() external onlyRegistry {
        LibEntity.load().active = true;
        emit Reactivated(msg.sender);
    }

    function remove(string memory reason) external onlyRegistry {

        LibEntity.load().removed = true;
        emit Removed(msg.sender, reason);
    }

    function isRemoved() external view returns (bool) {
        return LibEntity.load().removed;
    }

    function isEntityActive() external view returns (bool) {
        return LibEntity.load().active;
    }
}
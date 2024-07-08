// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {CommonInitArgs} from '../../interfaces/entity/IRegisteredEntity.sol';

contract RemovableEntityExt is IExtension, IRemovableEntity {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "AccessExt: restricted to admins");
        _;
    }

    modifier onlyRegistry {
        require(msg.sender == LibRemovableEntity.load().registry, "RemovableEntityExt: restricted to owning registry");
        _;
    }

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.REMOVABLE_ENTITY,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](7);
        sigs[0] = SelectorInfo({
            selector: this.deactivate.selector,
            name: "deactivate()"
        });
        sigs[1] = SelectorInfo({
            selector: this.reactivate.selector,
            name: "reactivate()"
        });
        sigs[2] = SelectorInfo({
            selector: this.remove.selector,
            name: "remove(string)"
        });
        sigs[3] = SelectorInfo({
            selector: this.isEntityActive.selector,
            name: "isEntityActive()"
        }); 
        sigs[4] = SelectorInfo({
            selector: this.isRemoved.selector,
            name: "isRemoved()"
        });
        sigs[5] = SelectorInfo({
            selector: this.name.selector,
            name: "name()"
        });
        sigs[6] = SelectorInfo({
            selector: this.termsOwner.selector,
            name: "termsOwner()"
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

    function init(CommonInitArgs calldata args) external {
       LibRemovableEntity.init(args);
    }


    function termsOwner() external view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    function deactivate(string memory reason) external onlyRegistry {
        LibRemovableEntity.load().active = false;
        emit EntityDeactivated(msg.sender, reason);
    }

    function reactivate() external onlyRegistry {
        LibRemovableEntity.load().active = true;
        emit EntityReactivated(msg.sender);
    }

    function remove(string memory reason) external onlyRegistry {
        LibRemovableEntity.load().removed = true;
        emit EntityRemoved(msg.sender, reason);
    }

    function isEntityActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isRemoved() external view returns (bool) {
        return LibRemovableEntity.load().removed;
    }

    function name() external view returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function version() external pure returns (Version memory) {
        revert("RemovableEntityExt: not implemented");
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../interfaces/IExtension.sol';
import {Version} from '../libraries/LibTypes.sol';
import {LibAccess} from '../libraries/LibAccess.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../libraries/LibExtensions.sol';
import {IAccessControl} from '../interfaces/IAccessControl.sol';
import {LibExtensionNames} from '../libraries/LibExtensionNames.sol';

contract AccessExt is IExtension, IAccessControl {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "AccessExt: restricted to admins");
        _;
    }

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "AccessExt: restricted to owner");
        _;
    }

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ACCESS,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](9);
        sigs[0] = SelectorInfo({
            selector: this.hasRole.selector,
            name: "hasRole(bytes32,address)"
        });
        sigs[1] = SelectorInfo({
            selector: this.grantRole.selector,
            name: "grantRole(bytes32,address)"
        });
        sigs[2] = SelectorInfo({
            selector: this.revokeRole.selector,
            name: "revokeRole(bytes32,address)"
        });
        sigs[3] = SelectorInfo({
            selector: this.addSigners.selector,
            name: "addSigners(address[])"
        });
        sigs[4] = SelectorInfo({
            selector: this.removeSigners.selector,
            name: "removeSigners(address[])"
        });
        sigs[5] = SelectorInfo({
            selector: this.isSigner.selector,
            name: "isSigner(address)"
        });
        sigs[6] = SelectorInfo({
            selector: this.isAdmin.selector,
            name: "isAdmin(address)"
        });
        sigs[7] = SelectorInfo({
            selector: this.owner.selector,
            name: "owner()"
        });
        sigs[8] = SelectorInfo({
            selector: this.changeOwner.selector,
            name: "changeOwner(address)"
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

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return LibAccess.hasRole(role, account);
    }

    function grantRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.revokeRole(role, account);
    }

    function addSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.addSigners(signers);
    }

    function removeSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.removeSigners(signers);
    }

    function isSigner(address account) external view returns (bool) {
        return LibAccess.isSigner(account);
    }

    function isAdmin(address account) external view returns (bool) {
        return LibAccess.isAdmin(account);
    }

    function owner() external view returns (address) {
        return LibAccess.owner();
    }

    function changeOwner(address newOwner) external onlyOwner {
        LibAccess.setOwner(newOwner);
    }
    
}
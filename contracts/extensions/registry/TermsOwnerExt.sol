// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibFactory} from '../../libraries/LibFactory.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';

contract TermsOwnerExt is IExtension, ITermsOwner {



     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.TERMS_OWNER,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](2);
        sigs[0] = SelectorInfo({
            selector: this.isStillActive.selector,
            name: "isStillActive()"
        });
        sigs[1] = SelectorInfo({
            selector: this.isTermsOwnerSigner.selector,
            name: "isTermsOwnerSigner(address)"
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

    function isStillActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }
    
    function isTermsOwnerSigner(address a) external view returns (bool) {
        return LibAccess.isSigner(a);
    }
    
}
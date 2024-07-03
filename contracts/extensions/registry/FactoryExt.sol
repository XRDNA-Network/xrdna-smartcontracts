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

contract FactoryExt is IExtension, IRegistryFactory {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "FactoryExt: restricted to admins");
        _;
    }

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.FACTORY,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](3);

        sigs[0] = SelectorInfo({
            selector: this.setEntityImplementation.selector,
            name: "setEntityImplementation(address)"
        });
        sigs[1] = SelectorInfo({
            selector: this.getEntityImplementation.selector,
            name: "getEntityImplementation()"
        });
        sigs[2] = SelectorInfo({
            selector: this.getEntityVersion.selector,
            name: "getEntityVersion()"
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

    function setEntityImplementation(address _entityImplementation) external {
        LibFactory.setEntityImplementation(_entityImplementation);
    }

    function getEntityImplementation() external view returns (address) {
        return LibFactory.getEntityImplementation();
    }

    function getEntityVersion() external view returns (Version memory) {
        return LibFactory.getEntityVersion();
    }
    
}
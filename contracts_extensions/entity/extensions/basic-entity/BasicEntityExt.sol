// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import { BaseExtension } from "../../../core/extensions/BaseExtension.sol";
import {IBasicEntityExt} from "./interfaces/IBasicEntityExt.sol";
import {ExtensionMetadata} from "../../../core/extensions/IExtension.sol";
import {AddSelectorArgs, SelectorArgs, LibExtensions} from "../../../core/LibExtensions.sol";
import {EntityStorage, LibEntity} from "../../libraries/LibEntity.sol";

contract BasicEntityExt is BaseExtension, IBasicEntityExt {

     modifier onlyFactory() {
        // This is a placeholder function that should be overridden by the entity the extension is installed in
        require(isYourFactory(msg.sender), "BasicEntityExt: caller is not the factory that created this entity");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.entity.BasicEntityExt", 1);
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) public virtual {
        SelectorArgs[] memory selectors = new SelectorArgs[](5);
        selectors[0] = SelectorArgs({
            selector: this.name.selector,
            isVirtual: false
        });
        selectors[1] = SelectorArgs({
            selector: this.version.selector,
            isVirtual: false
        });
        selectors[2] = SelectorArgs({
            selector: this.init.selector,
            isVirtual: true
        });
        selectors[3] = SelectorArgs({
            selector: this.isSigner.selector,
            isVirtual: true
        });
        selectors[4] = SelectorArgs({
            selector: this.isYourFactory.selector,
            isVirtual: true
        });
        AddSelectorArgs memory args = AddSelectorArgs({
            selectors: selectors,
            impl: myAddress
        });
        LibExtensions.addExtensionSelectors(args);
    }

    function initStorage(address, string calldata _name, uint256 _version, bytes calldata) external override {
        EntityStorage storage es = LibEntity.load();
        require(bytes(es.name).length == 0, "BasicEntityExt: already initialized");
        require(bytes(_name).length > 0, "BasicEntityExt: name cannot be empty");
        es.name = _name;
        es.version = _version;
        es.active = true;
        es.removed = false;
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress, uint256 currentVersion) public {
        //no-op
    }

    function isYourFactory(address) public pure virtual returns (bool) {
        revert("BasicEntityExt: isYourFactory not implemented");
    }


    function name() external view returns (string memory) {
        return LibEntity.load().name;
    }

    function version() external view returns (uint256) {
        return LibEntity.load().version;
    }

    function init(address, string calldata, bytes calldata) external pure {
        revert("BasicEntityExt: init not implemented");
    }

    function isSigner(address) external pure returns (bool) {
        revert("BasicEntityExt: isSigner not implemented");
    }
}
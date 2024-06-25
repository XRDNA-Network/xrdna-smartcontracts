// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtension} from "../BaseExtension.sol";
import {IHooksExtension} from "./interfaces/IHooksExtension.sol";
import {ExtensionMetadata} from "../IExtension.sol";
import {AddSelectorArgs, SelectorArgs, LibExtensions} from "../../LibExtensions.sol";
import {LibAccess} from "../../LibAccess.sol";
import {LibRoles} from "../../LibRoles.sol";
import {LibHook} from "./libraries/LibHook.sol";

contract HooksExtension is BaseExtension, IHooksExtension {


    function metadata() public override pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.core.HooksExt", 1);
    }

    function install(address myAddress) public virtual override {
        SelectorArgs[] memory selectors = new SelectorArgs[](3);
        selectors[0] = SelectorArgs({
            selector: this.setHook.selector,
            isVirtual: false
        });
        selectors[1] = SelectorArgs({
            selector: this.removeHook.selector,
            isVirtual: false
        });
        selectors[2] = SelectorArgs({
            selector: this.getHook.selector,
            isVirtual: true
        });
        AddSelectorArgs memory args = AddSelectorArgs({
            selectors: selectors,
            impl: myAddress
        });
        LibExtensions.addExtensionSelectors(args);
    }

    function upgrade(address myAddress, uint256 currentVersion) public {
        //no-op
    }

    function setHook(address _hook) public onlyOwner {
        LibHook.setHook(_hook);
    }

    function removeHook() public onlyOwner {
        LibHook.removeHook();
    }

    function getHook() external view returns (address) {
        return LibHook.getHook();
    }
    
}
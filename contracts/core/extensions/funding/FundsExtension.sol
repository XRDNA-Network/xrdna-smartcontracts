// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {BaseExtension} from "../BaseExtension.sol";
import {IFundsExtension} from "./interfaces/IFundsExtension.sol";
import {LibAccess} from "../../LibAccess.sol";
import {LibRoles} from "../../LibRoles.sol";
import {ExtensionMetadata} from "../IExtension.sol";
import {AddSelectorArgs, SelectorArgs, LibExtensions} from "../../LibExtensions.sol";

import "hardhat/console.sol";

contract FundsExtension is BaseExtension, IFundsExtension {


    function metadata() external override pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.core.FundsExt", 1);
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        console.log("Installing extension to", address(this), "Ext Address", myAddress);
        SelectorArgs[] memory selectors = new SelectorArgs[](1);
        selectors[0] = SelectorArgs({
            selector: this.withdraw.selector,
            isVirtual: false
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
    function upgrade(address myAddress, uint256 currentVersion) external {
        //no-op
    }

    function withdraw(uint256 amount) external onlyOwner {
        address owner = LibAccess.owner();
        require(owner != address(0), "LibFunds: owner not set");
        require(address(this).balance >= amount, "LibFunds: insufficient balance");
        payable(owner).transfer(amount); 
    }
}
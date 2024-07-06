// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {ERC20Storage, LibERC20} from '../../../libraries/LibERC20.sol';
import {BaseInfoExt} from '../BaseInfoExt.sol';

contract ERC20InfoExt is BaseInfoExt {

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() public pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ERC20_INFO,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) public {
        SelectorInfo[] memory sigs = new SelectorInfo[](9);
        sigs[0] = SelectorInfo({
            selector: super.name.selector,
            name: "name()"
        });
        sigs[1] = SelectorInfo({
            selector: super.symbol.selector,
            name: "symbol()"
        });
        sigs[2] = SelectorInfo({
            selector: super.issuer.selector,
            name: "issuer()"
        });
        sigs[3] = SelectorInfo({
            selector: super.originAddress.selector,
            name: "originAddress()"
        });
        sigs[4] = SelectorInfo({
            selector: super.originChainId.selector,
            name: "originChainId()"
        });
        sigs[5] = SelectorInfo({
            selector: this.decimals.selector,
            name: "decimals()"
        });
        sigs[6] = SelectorInfo({
            selector: this.totalSupply.selector,
            name: "totalSupply()"
        });
        sigs[7] = SelectorInfo({
            selector: this.balanceOf.selector,
            name: "balanceOf(address)"
        });
        sigs[8] = SelectorInfo({
            selector: this.allowance.selector,
            name: "allowance(address,address)"
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

    function decimals() public view returns (uint8) {
        return LibERC20.load().decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return LibERC20.load().totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return LibERC20.load().balances[account];
    }


    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return LibERC20.load().allowances[owner][spender];
    }

}
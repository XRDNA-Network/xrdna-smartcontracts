// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IExtension, ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {LibERC721} from '../../../libraries/LibERC721.sol';


contract ERC721TransferExt is IExtension {

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ERC721_TRANSFER,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](4);
        sigs[0] = SelectorInfo({
            selector: this.approve.selector,
            name: "approve(address,uint256)"
        });
        sigs[1] = SelectorInfo({
            selector: this.getApproved.selector,
            name: "getApproved(uint256)"
        });
        sigs[2] = SelectorInfo({
            selector: this.setApprovalForAll.selector,
            name: "setApprovalForAll(address,bool)"
        });
        sigs[3] = SelectorInfo({
            selector: this.transferFrom.selector,
            name: "transferFrom(address,address,uint256)"
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
     * @dev See {IERC721-approve}.
     */
    function approve(address, uint256) public pure returns (bool) {
        revert("NTERC721: token is non-transferable");
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        LibERC721.requireOwned(tokenId);

        return LibERC721._getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address, bool) public virtual {
        revert("NTERC721: token is non-transferable");
    }


    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address, address, uint256) public pure returns (bool) {
        revert("NTERC721: token is non-transferable");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address, address, uint256, bytes memory) public virtual {
        revert("NTERC721: token is non-transferable");
    }
}
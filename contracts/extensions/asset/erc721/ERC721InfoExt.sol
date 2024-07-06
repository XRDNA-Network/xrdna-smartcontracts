// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {ERC721Storage, LibERC721} from '../../../libraries/LibERC721.sol';
import {BaseInfoExt} from '../BaseInfoExt.sol';
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';

contract ERC721InfoExt is BaseInfoExt, IERC721Errors {

    using Strings for uint256;

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ERC721_INFO,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
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
            selector: this.supportsInterface.selector,
            name: "supportsInterface(bytes4)"
        });
        sigs[6] = SelectorInfo({
            selector: this.balanceOf.selector,
            name: "balanceOf(address)"
        });
        sigs[7] = SelectorInfo({
            selector: this.ownerOf.selector,
            name: "ownerOf(uint256)"
        });
        sigs[8] = SelectorInfo({
            selector: this.tokenURI.selector,
            name: "tokenURI(uint256)"
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
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual  returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }
        ERC721Storage storage s = LibERC721.load();
        return s.balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return LibERC721.requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        LibERC721.requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return LibERC721.load().baseURI;
    }

}
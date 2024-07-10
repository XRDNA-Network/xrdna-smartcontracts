// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IMintableAsset} from '../IMintableAsset.sol';

/**
    * @title IERC721Asset
    * @dev IERC721Asset represents a synthetic asset for any XR chain ERC721 tokens.
 */
interface IERC721Asset is IMintableAsset {

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ERC721Minted(address indexed to, uint256 indexed tokenId);

    /**
     * @dev returns whether given selector is supported by this contract
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    /**
     * @dev Returns owner of given token id
     */
    function ownerOf(uint256 tokenId) external view returns (address);

    /**
     * @dev Returns the uri used to retrieve token metadata
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Gets address approved to manage the given token ID
     */
    function getApproved(uint256 tokenId) external view returns (address);

    /**
     * @dev Set approval for a given address on all token ids
     */
    function setApprovalForAll(address, bool) external;

    /**
     * @dev Check if given address is approved for all token ids
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfer tokens from holder to new address. This requires approval from holder
     * and the receiver must implement ERC721Receiver interface
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Safely transfer tokens from holder to new address. This requires approval from holder
     * and the receiver must implement ERC721Receiver interface
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}
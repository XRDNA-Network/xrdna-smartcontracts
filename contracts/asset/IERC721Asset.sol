// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IBasicAsset} from './IBasicAsset.sol';

interface IERC721Asset is IBasicAsset, IERC721 {
    
    function mint(address to) external returns (uint256);
    function revoke(uint256 tokenId) external;
}
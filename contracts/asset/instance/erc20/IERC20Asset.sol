// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAsset} from '../IAsset.sol';

/**
 * @title IERC20Asset
 * @dev IERC20Asset represents a synthetic asset for any XR chain ERC20 tokens.
 */
interface IERC20Asset is IAsset {

    event ERC20Minted(address indexed to, uint256 indexed amt);

    /**
     * @dev Returns true if the asset can be minted to the given address with the given data
     */
    function canMint(address to, uint256 amt) external view returns (bool);

    /**
     * @dev Mints the asset to the given address with the given data. Only callable by the asset issuer
     * after verifying the minting parameters.
     */
    function mint(address to, uint256 amt) external;

    /**
     * @dev Revokes the asset from the given address with the given data. Only callable by the asset issuer
     */
    function revoke(address holder, uint256 amt) external;
    
    /**
        * @dev Returns the number of decimals for the asset (preferably aligned with original ERC20)
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the total supply of the asset (this only represents the XR chain supply,
     * not the original ERC20 supply)
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the any spend allowance for the spender on the owner's asset
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Transfers the asset to the recipient
     */
    function transfer(address, uint256) external returns (bool);
    

}
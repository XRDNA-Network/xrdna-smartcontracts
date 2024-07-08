// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAsset} from './IAsset.sol';

/**
 * @title IMintableAsset
 * @dev All assets in the interoperability layer are synthetic tokens that represent 
 * actual assets on other chains. These assets can only be minted and revoked by an issuing 
 * company after a private verification process has been completed. This interface is common
 * across all assets in the interoperability layer. They can be minted or revoked and checked
 * whether minting can occur.
 * 
 * The actual parameters for minting/revoking are bytes so that any asset can be 
 * represented through this generic interface. We anticipate many asset types being
 * added to the system and therefore left the arguments flexible for future extensibility.
 */
interface IMintableAsset is IAsset {

    /**
     * @dev Returns true if the asset can be minted to the given address with the given data
     */
    function canMint(address to, bytes calldata data) external view returns (bool);

    /**
     * @dev Mints the asset to the given address with the given data. Only callable by the asset issuer
     * after verifying the minting parameters.
     */
    function mint(address to, bytes calldata data) external;

    /**
     * @dev Revokes the asset from the given address with the given data. Only callable by the asset issuer
     */
    function revoke(address holder, bytes calldata data) external;
    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * Some assets may require customization when minting and transferring assets. This interface
 * allows an issuing company to extend the default behavior for minting and transfers.
 */
interface IAssetHook {

    /**
     * Called to check with hook that minting the agiven asset to the given address is ok
     * @return false means the minting process should NOT proceed.
     */
    function canMint(address asset, address to, uint256 amtOrTokenId) external view returns (bool);

    /**
     * Called before minting assets to the given 'to' address. 
     * @return false means the minting process should NOT proceed.
     */
    function beforeMint(address asset, address to, uint256 amtOrTokenId) external returns (bool);

    /**
     * Called before revoking tokens from a target address.
     * @return false means revoking should NOT proceed 
     */
    function beforeRevoke(address asset, address target, uint256 amtOrTokenId) external returns (bool);

    /**
     * Called before a transfer occurs. 
     * @return false means the transfer should NOT proceed.
     */
    function beforeTransfer(address asset, address to, uint256 amtOrTokenId) external returns (bool);
}
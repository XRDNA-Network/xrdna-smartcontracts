// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IAssetMinting {


    event ERC20Minted(address indexed to, uint256 indexed amt);
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
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
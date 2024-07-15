// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';

/**
 * @dev Common asset creation arguments. Used by the registry to create new assets.
 */
struct CreateAssetArgs {
    //the address allowed to mint/burn the asset
    address issuer;

    //the address of the asset on the origin chain
    address originAddress;

    //the chain id of the origin chain
    uint256 originChainId;

    //name of the asset
    string name;

    //its symbol
    string symbol;

    //extra init data interpreted by the concrete asset implementation
    bytes initData;
}

interface IAssetRegistry is IRemovableRegistry {
    
    /**
     * @dev Determines if the asset from the original chain has been registered
     */
    function assetExists(address original, uint256 chainId) external view returns (bool);


    /**
     * @dev Registers a new asset with the registry. Only callable by the registry admin
     * after verifying ownership by the issuing company.
     */
    function registerAsset(CreateAssetArgs calldata args) external returns (address asset);

    /**
     * @dev Deactivates an asset. Only callable by the registry admin
     */
    function deactivateAsset(address asset, string calldata reason) external;

    /**
     * @dev Reactivates an asset. Only callable by the registry admin
     */
    function reactivateAsset(address asset) external;

    /**
     * @dev Removes an asset from the registry. Only callable by the registry admin
     * after the registration grace period has expired
     */
    function removeAsset(address asset, string calldata reason) external;
}
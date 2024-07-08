// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';

struct CreateAssetArgs {
    address issuer;
    address originAddress;
    uint256 originChainId;
    string name;
    string symbol;
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

    function deactivateAsset(address asset, string calldata reason) external;

    function reactivateAsset(address asset) external;

    /**
     * @dev Removes an asset from the registry. Only callable by the registry admin
     */
    function removeAsset(address asset, string calldata reason) external;
}
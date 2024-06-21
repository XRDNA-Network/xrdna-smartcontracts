// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AssetCheckArgs} from './IAssetCondition.sol';

/**
 * @title IAssetRegistry
 * @dev This interface should be implemented by an asset registry to allow for the registration
 * and management of assets. The registry is responsible for keeping track of all assets and
 * their versions, as well as providing the ability to register, upgrade, and remove assets.
 */
interface IAssetRegistry {
    
    /**
     * @dev Admin can use this to change the asset factory used to create new assets
     */
    function setAssetFactory(address factory) external;

    /**
     * @dev Returns the current version of the assets created by the registry's underlying factory
     */
    function currentAssetVersion() external view returns (uint256);

    /**
     * @dev Determines if the asset from the original chain has been registered
     */
    function assetExists(address original, uint256 chainId) external view returns (bool);

    /**
     * @dev Determines if the asset is a registered asset that can be used by the 
     * interoperability layer
     */
    function isRegisteredAsset(address asset) external view returns (bool);

    /**
     * @dev Registers a new asset with the registry. Only callable by the registry admin
     * after verifying ownership by the issuing company.
     */
    function registerAsset(bytes calldata initData) external returns (address asset);

    /**
     * @dev Upgrades an existing asset to a new version. Only callable by the asset itself
     */
    function upgradeAsset(bytes calldata initData) external returns (address);

    /**
     * @dev Removes an asset from the registry. Only callable by the registry admin
     */
    function removeAsset(address asset) external;
}
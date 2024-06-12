// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBaseFactory} from '../IBaseFactory.sol';

/**
 * @title IAssetFactory
 * @dev This interface should be implemented by an asset factory to allow for the creation
 * and upgrading of assets. The factory is responsible for creating new assets and upgrading
 * existing assets to new versions. It extends basic factory functionality.
 */
interface IAssetFactory is IBaseFactory {

    /**
     * @dev Upgrades an existing asset to a new version. Only callable by the asset itself
     * when its issuer decides to upgrade its logic to the latest version.
     */
    function upgradeAsset(address asset, bytes calldata initData) external;

    /**
     * @dev Creates a new asset instance. Only callable by administrator of the asset registry
     */
    function createAsset(bytes calldata initData) external returns (address asset);
}
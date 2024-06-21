// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IAssetHook} from './IAssetHook.sol';
import {IAssetCondition, AssetCheckArgs} from './IAssetCondition.sol';
import {ISupportsHook} from '../ISupportsHook.sol';

/**
 * @title IBasicAsset
 * @dev This interface should be implemented by all assets to provide basic asset functionality
 */
interface IBasicAsset is ISupportsHook {

    /**
     * @dev Initializes the asset with the given data. This function should only be called once 
     * by the asset factory.
     */
    function init(bytes calldata data) external;

    /**
     * @dev Returns the contract version of the asset. Can be compared with registry or 
     * factory's version to determine if upgrade is available.
     */
    function version() external view returns (uint256);

    /**
     * @dev Returns the address of the asset's issuer
     */
    function issuer() external view returns (address);

    /**
     * @dev Called by the asset issuer to upgrade the asset to the latest version.
     * Init data will depend on upgrade implementation.
     */
    function upgrade(bytes calldata data) external returns (address);

    /**
     * @dev Get the address of the original asset that this synthetic asset represents
     */
    function originAddress() external view returns(address);

    /**
     * @dev Get the chain id of the original asset that this synthetic asset represents
     */
    function originChainId() external view returns(uint256);

    /**
     * @dev Add a condition to the asset to restrict its use or viewing. This can only be
     * called by the asset issuer (company contract)
     */
    function addCondition(IAssetCondition condition) external;

    /**
     * @dev Remove the condition from the asset. Can only be called by the asset issuer
     * (company contract)
     */
    function removeCondition() external;

    /**
     * @dev Check if the asset can be viewed by the given world, company, experience, and avatar
     * based on the conditions set by the issuer
     */
    function canViewAsset(AssetCheckArgs memory args) external view returns (bool);

    /**
     * @dev Check if the asset can be used by the given world, company, experience, and avatar
     * based on the conditions set by the issuer
     */
    function canUseAsset(AssetCheckArgs memory args) external view returns (bool);

    /**
     * @dev Called by the asset factory to notify the asset that it has been upgraded to a new version
     */
    function upgradeComplete(address nextVersion) external;
}
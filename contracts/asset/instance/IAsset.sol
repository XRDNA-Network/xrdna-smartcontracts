// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {AssetCheckArgs} from '../IAssetCondition.sol';

/**
 * @dev Basic initialization arguments for an asset
 */
struct AssetInitArgs {
    //name of the asset
    string name; 

    //its symbol
    string symbol;

    //the address allowed to mint/burn the asset
    address issuer; 

    //the address of the asset on the origin chain
    address originAddress;

    //the chain id of the origin chain
    uint256 originChainId;

    //extra init data interpreted by the concrete asset implementation
    bytes initData;
}

/**
    * @title IAsset
    * @dev IAsset is the base interface for all assets. It provides the basic
    * functionality for asset management, including the ability to add and remove
    * conditions, as well as the ability to verify that an asset can be viewed or 
    * used.
 */
interface IAsset is IRemovableEntity {

    event AssetConditionSet(address condition);
    event AssetConditionRemoved();

    /**
     * @dev Initializes the asset with the given arguments. This method is called
     * only once when the asset is cloned.
     */
    function init(AssetInitArgs calldata args) external;

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the issuer (company) allowed to mint/burn the asset.
     */
    function issuer() external view returns (address);

    /**
     * @dev Returns the address of the asset on the origin chain.
     */
    function originAddress() external view returns (address);

    /**
     * @dev Returns the chain id of the origin chain.
     */
    function originChainId() external view returns (uint256);

    /**
     * @dev Returns the balance of assets for the given holder
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Approves spending asset for given spender
     */
    function approve(address, uint256) external returns (bool); 

    /**
        * @dev Transfers asset from sender to given recipient
     */
    function transferFrom(address, address, uint256) external returns (bool);

    /**
     * @dev sets a condition on the asset for viewing/using
     */
    function setCondition(address condition) external;

    /**
     * @dev removes the condition on the asset for viewing/using
     */
    function removeCondition() external;

    /**
     * @dev Checks if the asset can be viewed based on the world/company/experience/avatar
     */
    function canViewAsset(AssetCheckArgs memory args) external view returns (bool);

    /**
     * @dev Checks if the asset can be used based on the world/company/experience/avatar
     */
    function canUseAsset(AssetCheckArgs memory args) external view returns (bool);

}
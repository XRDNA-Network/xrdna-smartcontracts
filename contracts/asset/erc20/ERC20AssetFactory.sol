// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {BaseFactory} from '../../BaseFactory.sol';
import {IAssetFactory} from '../IAssetFactory.sol';
import {IMintableAsset} from '../IMintableAsset.sol';
import {IBaseProxy} from '../../IBaseProxy.sol';

/**
 * @title ERC20AssetFactory
 * @dev Factory contract to create new ERC20 assets
 * The factory is used to create new ERC20 assets and upgrade them to the next version. 
 * See BaseFactory on proxy patterns used.
 */
contract ERC20AssetFactory is BaseFactory, IAssetFactory {

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    /**
     * @dev Upgrades an asset to the latest version
     * @param asset Address of the asset to upgrade
     * @param initData Data to initialize the new version of the asset
     */
    function upgradeAsset(address asset, bytes calldata initData) external override returns (address) {
        //to upgrade an asset, we just need to change its underlying implementation. 
        //so first, make sure the asset doesn't already have the latest implementation
        address impl = IBaseProxy(asset).getImplementation();
        require(impl != implementation, "Already on the latest version");

        //and if it does, go ahead and complete the upgrade which should switch
        //the asset proxy's underlying implementation address to the new master version
        IMintableAsset(asset).upgradeComplete(implementation);

        //initialize the new implementation with the provided data
        IMintableAsset(asset).init(initData);
        return implementation;
    }

    /**
     * @dev Creates a new ERC20 asset
     * @param initData Data to initialize the new asset
     * @return asset Address of the new asset
     */
    function createAsset(bytes calldata initData) external override returns (address asset) {
        //we just need to clone the master proxy contract and initialize it with the 
        //implementation master copy implementation address
        asset = createProxy();
        IBaseProxy(asset).initProxy(implementation);
        
        //then initialize the new proxy with init data
        IMintableAsset(asset).init(initData);
    }
}
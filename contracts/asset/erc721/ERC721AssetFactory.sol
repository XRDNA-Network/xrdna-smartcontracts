// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {BaseFactory} from '../../BaseFactory.sol';
import {IAssetFactory} from '../IAssetFactory.sol';
import {IMintableAsset} from '../IMintableAsset.sol';
import {IBaseProxy} from '../../IBaseProxy.sol';


 /* @title ERC721AssetFactory
 * @dev Factory contract to create new ERC721assets
 * The factory is used to create new ERC721 assets and upgrade them to the next version. 
 * See BaseFactory on proxy patterns used.
 */
contract ERC721AssetFactory is BaseFactory, IAssetFactory {

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function upgradeAsset(address asset, bytes calldata initData) external override {
        IMintableAsset(asset).upgradeComplete(implementation);
        IMintableAsset(asset).init(initData);
    }

    function createAsset(bytes calldata initData) external override returns (address asset) {
        asset = createProxy();
        IBaseProxy(asset).initProxy(implementation);
        IMintableAsset(asset).init(initData);
    }
}
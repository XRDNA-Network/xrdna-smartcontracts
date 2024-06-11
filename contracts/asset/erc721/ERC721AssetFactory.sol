// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {BaseFactory} from '../../BaseFactory.sol';
import {IAssetFactory} from '../IAssetFactory.sol';
import {IMintableAsset} from '../IMintableAsset.sol';
import {IBaseProxy} from '../../IBaseProxy.sol';

interface INextERC721Version {
    function init(bytes calldata initData) external;
}

contract ERC721AssetFactory is BaseFactory, IAssetFactory {

    uint256 public constant override supportsVersion = 1;

    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}

    function upgradeAsset(address asset, bytes calldata initData) external override {
        IMintableAsset(asset).upgradeComplete(implementation);
        INextERC721Version(asset).init(initData);
    }

    function createAsset(bytes calldata initData) external override returns (address asset) {
        asset = createProxy();
        IBaseProxy(asset).initProxy(implementation);
        IMintableAsset(asset).init(initData);
    }
}
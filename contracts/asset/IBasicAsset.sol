// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IAssetHook} from './IAssetHook.sol';
import {IAssetCondition, AssetCheckArgs} from './IAssetCondition.sol';

interface IBasicAsset {

    function init(bytes calldata data) external;
    function version() external view returns (uint256);
    function issuer() external view returns (address);
    function upgrade(bytes calldata data) external;
    function originAddress() external view returns(address);
    function originChainId() external view returns(uint256);
    function addHook(IAssetHook hook) external;
    function removeHook() external;
    function addCondition(IAssetCondition condition) external;
    function removeCondition() external;

    function canViewAsset(AssetCheckArgs memory args) external view returns (bool);
    function canUseAsset(AssetCheckArgs memory args) external view returns (bool);
    function upgradeComplete(address nextVersion) external;
}
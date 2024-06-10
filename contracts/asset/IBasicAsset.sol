// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IAssetHook} from './IAssetHook.sol';

interface IBasicAsset {
    function assetType() external view returns (uint256);
    function version() external view returns (uint256);
    function issuer() external view returns (address);
    function upgrade(address newAsset) external;
    function originAddress() external view returns(address);
    function originChainId() external view returns(uint256);
    function addHook(IAssetHook hook) external;
    function removeHook() external;
}
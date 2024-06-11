// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../BaseRegistry.sol';
import {IMintableAsset} from '../IMintableAsset.sol';

contract ERC721AssetRegistry is BaseRegistry {

    event ERC721AssetCreated(address indexed asset, address indexed issuer, address indexed originAddress, uint256 originChainId);

    constructor(address mainAdmin, address[] memory admins, address factory) BaseRegistry(mainAdmin, admins, factory) {}

    function registerAsset(bytes calldata initData) external onlyAdmin returns (address asset) {
        require(address(assetFactory) != address(0), "AssetRegistry: asset factory not set");
        
        asset = assetFactory.createAsset(initData);
        IMintableAsset ba = IMintableAsset(asset);
        bytes32 hash = keccak256(abi.encode(ba.originAddress(), ba.originChainId()));
        require(assetsByOriginalAddressAndChain[hash] == address(0), "AssetRegistry: asset already registered");
        
        registeredAssets[asset] = true;
        assetsByOriginalAddressAndChain[hash] = asset;
        
        emit ERC721AssetCreated(asset, ba.issuer(), ba.originAddress(), ba.originChainId());
    }

    
} 
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../BaseRegistry.sol';
import {IMintableAsset} from '../IMintableAsset.sol';

/**
 * @title ERC20AssetRegistry
 * @dev Registry contract for ERC20 assets
 * The registry is used to register new ERC20 assets and make sure that only registered
 * assets are used in the interoperability protocol.
 */
contract ERC20AssetRegistry is BaseRegistry {

    event ERC20AssetCreated(address indexed asset, address indexed issuer, address indexed originAddress, uint256 originChainId);

    /**
     * @dev Creates a new ERC20 asset registry
     * @param mainAdmin Address of an admin that can change roles for the registry. Consider
     * it a more privileged admin that can add or remove other admins.
     * @param admins List of initial admins for the registry with no role-assignment privileges.
     * Admin are allowed to register new assets. This is locked down to prevent anyone from
     * creating arbitrary assets that are not verified. Verified, in this context, means that 
     * the issuing Company does, in fact, "own" or control the asset on an origin chain.
     */
    constructor(address mainAdmin, address[] memory admins, address factory) BaseRegistry(mainAdmin, admins, factory) {}

    /**
     * @dev Registers a new ERC20 asset
     * @param initData Data to initialize the new asset
     * @return asset Address of the new asset
     * This can only be called by authorized admins that have verified asset ownership by the 
     * issuer on its origin chain.
     */
    function registerAsset(bytes calldata initData) external onlyAdmin returns (address asset) {
        require(address(assetFactory) != address(0), "AssetRegistry: asset factory not set");
        
        //clone the asset contract (proxy) and initialize it with the given data
        asset = assetFactory.createAsset(initData);

        //hash the origin address and chain id to create a unique key for the asset so we know
        //whether it has been created already in this registry
        IMintableAsset ba = IMintableAsset(asset);
        bytes32 hash = keccak256(abi.encode(ba.originAddress(), ba.originChainId()));
        require(assetsByOriginalAddressAndChain[hash] == address(0), "AssetRegistry: asset already registered");
        
        registeredAssets[asset] = true;
        assetsByOriginalAddressAndChain[hash] = asset;
        
        emit ERC20AssetCreated(asset, ba.issuer(), ba.originAddress(), ba.originChainId());
    }

    
} 
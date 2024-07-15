// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct AssetRegistryStorage {
    mapping(bytes32 => address) assetsByOriginChain;
}

/**
    * @title LibAssetRegistry
    
    * @dev The asset registry library provides functions to get storage for any asset registry type.
 */
library LibAssetRegistry {

    function load() internal pure returns (AssetRegistryStorage storage store) {
        bytes32 slot = LibStorageSlots.ASSET_REGISTRY;
        assembly {
            store.slot := slot
        }
    }

    /**
     * @dev Checks if an asset has been registered based on its origin chain info.
     * @param original The original asset address.
     * @param chainId The chain ID.
     * @return True if the asset has been registered, false otherwise.
     */
    function assetExists(address original, uint256 chainId) internal view returns (bool) {
        return load().assetsByOriginChain[keccak256(abi.encode(original, chainId))] != address(0);
    }

    /**
     * @dev Marks an asset as registered based on its origin chain info.
     * @param original The original asset address.
     * @param chainId The chain ID.
     * @param asset The asset address.
     */
    function markAssetExists(address original, uint256 chainId, address asset) internal {
        load().assetsByOriginChain[keccak256(abi.encode(original, chainId))] = asset;
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct AssetRegistryStorage {
    mapping(bytes32 => address) assetsByOriginChain;
}

library LibAssetRegistry {

    function load() internal pure returns (AssetRegistryStorage storage store) {
        bytes32 slot = LibStorageSlots.ASSET_REGISTRY;
        assembly {
            store.slot := slot
        }
    }

    function assetExists(address original, uint256 chainId) internal view returns (bool) {
        return load().assetsByOriginChain[keccak256(abi.encode(original, chainId))] != address(0);
    }

    function markAssetExists(address original, uint256 chainId, address asset) internal {
        load().assetsByOriginChain[keccak256(abi.encode(original, chainId))] = asset;
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../libraries/LibStorageSlots.sol';
import {IAssetCondition} from '../asset/IAssetCondition.sol';

struct AssetStorage {
    bool active;

    bool removed;
    
    //the contract address on the origin chain
    address originAddress;

    //the address allowed to mint new tokens
    address issuer;

    //custom view/use conditions
    IAssetCondition condition;

    //original chain id
    uint256 originChainId;

    string symbol;
}

library LibAsset {
    function load() internal pure returns (AssetStorage storage store) {
        bytes32 slot = LibStorageSlots.ASSET_STORAGE;
        assembly {
            store.slot := slot
        }
    }
}
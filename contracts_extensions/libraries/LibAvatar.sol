// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';
import {LinkedList} from './LibLinkedList.sol';

struct Wearable {
    address asset;
    uint256 tokenId;
}


struct AvatarStorage {
    bool canReceiveTokensOutsideExperience;
    address currentExperience;
    mapping(address => uint256) companyNonces;
    uint256 ownerNonce;
    bytes appearanceDetails;

    //list of wearables the avatar is wearing
    LinkedList list;
}

library LibAvatar {

    function load() internal pure returns (AvatarStorage storage ds) {
        bytes32 slot = LibStorageSlots.AVATAR_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

}
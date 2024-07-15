// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from './LibStorageSlots.sol';
import {LinkedList} from './LibLinkedList.sol';

/**
 * @dev wearable structure assumed to be an NFT asset contract with unique token id. The tokenId
 * is the XR chain id, not the original NFT token id.
 */
struct Wearable {
    address asset;
    uint256 tokenId;
}


//storage for avatar
struct AvatarStorage {

    //whether the avatar owner allows NFTs to be minted from any company vs restricting 
    //minting to only companies who own the experience the Avatar is currently in.
    bool canReceiveTokensOutsideExperience;

    //address of the experience where the avatar is located
    address currentExperience;

    //nonces used by companies to sign jump requests.
    mapping(address => uint256) companyNonces;

    //owner nonce used to sign delegated jump requests (those where company pays txn fees)
    uint256 ownerNonce;

    //custom avatar client appearance data, if applicable
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
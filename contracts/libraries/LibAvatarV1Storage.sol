// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IExperience} from '../experience/IExperience.sol';
import {IAvatarHook} from '../avatar/IAvatarHook.sol';
import {LinkedList} from './LibLinkedList.sol';

/**
 * @dev An Avatar wearable represents an NFT contract and token id
 */
struct Wearable {
    address asset;
    uint256 tokenId;
}

/**
 * Storage data for AvatarV1
 */
struct AvatarV1Storage {
    //whether the owner has opted in to receive tokens outside of experiences (i.e. random airdrops)
    bool canReceiveTokensOutsideOfExperience;

    //owner of the avatar
    address owner;

    //current experience the avatar is in
    IExperience location;

    //customization hook installed by owner
    IAvatarHook hook;

    //avatar's globally unique username
    string username;

    //avatar's appearance details, which depends on avatar implementation offchain
    bytes appearanceDetails;

    //nonces used for company signatures approving avatar jumps. This is to avoid replay attacks
    mapping (address => uint256) companySigningNonce;

    //nonce used by avatar owner to sign delegated jump requests for companies. This is to 
    //avoid replay attacks
    uint256 avatarOwnerSigningNonce;

    //list of wearables the avatar is wearing
    LinkedList list;
}


/**
 * @dev Library for AvatarV1Storage
 */
library LibAvatarV1Storage {
    
        bytes32 public constant AVATAR_V1_STORAGE_SLOT = keccak256("_AvatarV1Storage");
    
        /**
         * @dev Load AvatarV1Storage from storage
         */
        function load() internal pure returns (AvatarV1Storage storage s) {
            bytes32 slot = AVATAR_V1_STORAGE_SLOT;
            assembly {
                s.slot := slot
            }
        }
}
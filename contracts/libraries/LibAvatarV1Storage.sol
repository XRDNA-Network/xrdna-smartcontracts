// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IExperience} from '../experience/IExperience.sol';
import {IAvatarHook} from '../avatar/IAvatarHook.sol';


struct Wearable {
    address asset;
    uint256 tokenId;
}

struct Node {
        Wearable data;
        bytes32 prev;
        bytes32 next;
}

    // Define the linked list structure
struct LinkedList {
        bytes32 head;
        bytes32 tail;
        uint256 size;
        mapping(bytes32 => Node) nodes;
}

struct AvatarV1Storage {
    //fields set by init data
    bool canReceiveTokensOutsideOfExperience;
    bool upgraded;
    address owner;
    IExperience location;
    IAvatarHook hook;
    string username;
    bytes appearanceDetails;
    mapping (address => uint256) companySigningNonce;
    uint256 avatarOwnerSigningNonce;

    LinkedList list;
}


library LibAvatarV1Storage {
    
        bytes32 public constant AVATAR_V1_STORAGE_SLOT = keccak256("_AvatarV1Storage");
    
        function load() internal pure returns (AvatarV1Storage storage s) {
            bytes32 slot = AVATAR_V1_STORAGE_SLOT;
            assembly {
                s.slot := slot
            }
        }
}
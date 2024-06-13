// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Wearable, AvatarV1Storage, LibAvatarV1Storage} from '../libraries/LibAvatarV1Storage.sol';  
import {LinkedList, LibLinkedList} from '../libraries/LibLinkedList.sol';

/**
 * @title LinkedList
 * @dev A doubly linked list of wearables for avatars. Because avatars will add and 
 * remove wearables frequently, a linked list is the most efficient data structure vs. 
 * arrays. Maps would be good except that we need to iterate over the list in order to
 * get all the wearables.
 */
abstract contract WearableLinkedList {
    
    using LibLinkedList for LinkedList;

    uint256 public constant MAX_SIZE = 200;

    // Modifier to check if the list is not empty
    modifier notEmpty() {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        require(s.list.size > 0, "List is empty");
        _;
    }

    // Modifier to check if the list is not full
    modifier notFull() {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        require(s.list.size < MAX_SIZE, "List is full");
        _;
    }

    // Function to insert a new address at the end of the list
    function insert(Wearable memory wearable) internal notFull {
        require(wearable.asset != address(0), "Invalid address");
        require(wearable.tokenId > 0, "Invalid tokenId");
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        LinkedList storage list = s.list;
        list.insert(wearable);
    }

    // Function to remove an address from the list
    function remove(Wearable memory wearable) internal {
        (address data, uint256 tokenId) = (wearable.asset, wearable.tokenId);
        require(data != address(0), "Invalid address");
        require(tokenId > 0, "Invalid token id");
        
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        LinkedList storage list = s.list;
        list.remove(wearable);
    }

    // Function to get the size of the list
    function getSize() internal view returns (uint256) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.list.size;
    }

    function contains(Wearable memory wearable) internal view returns (bool) {
        (address data, uint256 tokenId) = (wearable.asset, wearable.tokenId);
        require(data != address(0), "Invalid address");
        require(tokenId > 0, "Invalid token id");
        bytes32 wHash = keccak256(abi.encode(data, tokenId));
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.list.nodes[wHash].data.asset != address(0);
    }

    function getAllItems() internal view returns (Wearable[] memory) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        LinkedList storage list = s.list;
        Wearable[] memory items = new Wearable[](list.size);
        bytes32 current = list.head;
        for (uint256 i = 0; i < list.size; i++) {
            items[i] = list.nodes[current].data;
            current = list.nodes[current].next;
        }
        return items;
    }
}
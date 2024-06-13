// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Wearable, LinkedList, Node, AvatarV1Storage, LibAvatarV1Storage} from '../libraries/LibAvatarV1Storage.sol';  

/**
 * @title LinkedList
 * @dev A doubly linked list of wearables for avatars. Because avatars will add and 
 * remove wearables frequently, a linked list is the most efficient data structure vs. 
 * arrays. Maps would be good except that we need to iterate over the list in order to
 * get all the wearables.
 */
abstract contract WearableLinkedList {
    
    
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
        bytes32 wHash = keccak256(abi.encodePacked(wearable.asset, wearable.tokenId));
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        LinkedList storage list = s.list;
        require(list.nodes[wHash].data.asset == address(0), "Address already in list");

        Node memory newNode = Node({
            data: wearable,
            prev: list.tail,
            next: bytes32(0)
        });

        if (list.size == 0) {
            list.head = wHash;
            list.tail = wHash;
        } else {
            list.nodes[list.tail].next = wHash;
            list.tail = wHash;
        }

        list.nodes[wHash] = newNode;
        list.size++;
    }

    // Function to remove an address from the list
    function remove(Wearable memory wearable) internal {
        (address data, uint256 tokenId) = (wearable.asset, wearable.tokenId);
        require(data != address(0), "Invalid address");
        require(tokenId > 0, "Invalid token id");
        bytes32 wHash = keccak256(abi.encode(data, tokenId));
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        LinkedList storage list = s.list;

        if(list.nodes[wHash].data.asset == address(0)) {
            return;
        }

        Node memory node = list.nodes[wHash];

        if (node.prev != bytes32(0)) {
            list.nodes[node.prev].next = node.next;
        } else {
            list.head = node.next;
        }

        if (node.next != bytes32(0)) {
            list.nodes[node.next].prev = node.prev;
        } else {
            list.tail = node.prev;
        }

        delete list.nodes[wHash];
        list.size--;
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
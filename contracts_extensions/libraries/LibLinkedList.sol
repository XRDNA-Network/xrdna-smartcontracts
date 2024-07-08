// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IExperience} from '../experience/instance/IExperience.sol';
import {Wearable} from './LibAvatar.sol';
import {IMintableAsset} from '../asset/IMintableAsset.sol';

/**
 * @dev node within a linked list structure where next/prev values are hashes of 
 * wearable asset/tokenId
 */
struct Node {
        Wearable data;
        bytes32 prev;
        bytes32 next;
}

/**
 * @dev LinkedList structure to store wearable assets
 */
struct LinkedList {

        bytes32 head;
        bytes32 tail;
        uint256 size;
        uint256 maxSize;
        //mapping of asset/tokenId hash to node
        mapping(bytes32 => Node) nodes;
}

/**
 * @dev Library to manage linked list of wearables
 */
library LibLinkedList {

    /**
     * @dev Insert a new wearable into the linked list
     */
    function insert(LinkedList storage list, Wearable memory wearable) external {
        //make sure list isn't full
        require(list.size < list.maxSize, "List is full");

        //hash the asset/tokenId pair
        bytes32 wHash = keccak256(abi.encode(wearable.asset, wearable.tokenId));
        require(list.nodes[wHash].data.asset == address(0), "Wearable already in list");

        //create node to hold wearable and pointers
        Node memory newNode = Node({
            data: wearable,
            prev: list.tail,
            next: bytes32(0)
        });

        //if list is empty
        if (list.size == 0) {
            //just set head tail to new node
            list.head = wHash;
            list.tail = wHash;
        } else {
            //otherwise insert at end of list
            list.nodes[list.tail].next = wHash;
            list.tail = wHash;
        }

        //store node by its hash
        list.nodes[wHash] = newNode;
        list.size++;
    }

    /**
     * @dev remove a wearable from the list
     */
    function remove(LinkedList storage list, Wearable memory wearable) external {
        bytes32 wHash = keccak256(abi.encode(wearable.asset, wearable.tokenId));
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

    /**
     * @dev check if the list contains a wearable
     */
    function contains(LinkedList storage list, Wearable memory wearable) external view returns (bool) {
        (address data, uint256 tokenId) = (wearable.asset, wearable.tokenId);
        require(data != address(0), "Invalid address");
        require(tokenId > 0, "Invalid token id");
        bytes32 wHash = keccak256(abi.encode(data, tokenId));
        return list.nodes[wHash].data.asset != address(0);
    }

    /**
     * @dev Get all wearables in the list. The list has a max capacity to prevent
     * gas exhaustion for read-only calls.
     */
    function getAllItems(LinkedList storage list) external view returns (Wearable[] memory) {
        Wearable[] memory items = new Wearable[](list.size);
        bytes32 current = list.head;
        for (uint256 i = 0; i < list.size; i++) {
            items[i] = list.nodes[current].data;
            current = list.nodes[current].next;
        }
        return items;
    }
}
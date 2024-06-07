// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct Wearable {
    address asset;
    uint256 tokenId;
}

/**
 * @title LinkedList
 * @dev A doubly linked list of addresses for use in other contracts when they need 
 * fast insert and delete operations.
 */
abstract contract WearableLinkedList {
    
    // Define a node in the doubly linked list
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

    LinkedList private list;
    uint256 public constant MAX_SIZE = 200;

    // Modifier to check if the list is not empty
    modifier notEmpty() {
        require(list.size > 0, "List is empty");
        _;
    }

    // Modifier to check if the list is not full
    modifier notFull() {
        require(list.size < MAX_SIZE, "List is full");
        _;
    }

    // Function to insert a new address at the end of the list
    function insert(Wearable memory wearable) internal notFull {
        require(wearable.asset != address(0), "Invalid address");
        require(wearable.tokenId > 0, "Invalid tokenId");
        bytes32 wHash = keccak256(abi.encodePacked(wearable.asset, wearable.tokenId));
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
        return list.size;
    }

    function contains(Wearable memory wearable) internal view returns (bool) {
        (address data, uint256 tokenId) = (wearable.asset, wearable.tokenId);
        require(data != address(0), "Invalid address");
        require(tokenId > 0, "Invalid token id");
        bytes32 wHash = keccak256(abi.encode(data, tokenId));
        return list.nodes[wHash].data.asset != address(0);
    }

    function getAllItems() internal view returns (Wearable[] memory) {
        Wearable[] memory items = new Wearable[](list.size);
        bytes32 current = list.head;
        for (uint256 i = 0; i < list.size; i++) {
            items[i] = list.nodes[current].data;
            current = list.nodes[current].next;
        }
        return items;
    }
}
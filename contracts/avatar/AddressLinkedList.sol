// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * @title LinkedList
 * @dev A doubly linked list of addresses for use in other contracts when they need 
 * fast insert and delete operations.
 */
abstract contract AddressLinkedList {
    
    // Define a node in the doubly linked list
    struct Node {
        address data;
        address prev;
        address next;
    }

    // Define the linked list structure
    struct LinkedList {
        address head;
        address tail;
        uint256 size;
        mapping(address => Node) nodes;
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
    function insert(address data) internal notFull {
        require(data != address(0), "Invalid address");
        require(list.nodes[data].data == address(0), "Address already in list");

        Node memory newNode = Node({
            data: data,
            prev: list.tail,
            next: address(0)
        });

        if (list.size == 0) {
            list.head = data;
            list.tail = data;
        } else {
            list.nodes[list.tail].next = data;
            list.tail = data;
        }

        list.nodes[data] = newNode;
        list.size++;
    }

    // Function to remove an address from the list
    function remove(address data) internal {
        require(data != address(0), "Invalid address");
        if(list.nodes[data].data == address(0)) {
            return;
        }

        Node memory node = list.nodes[data];

        if (node.prev != address(0)) {
            list.nodes[node.prev].next = node.next;
        } else {
            list.head = node.next;
        }

        if (node.next != address(0)) {
            list.nodes[node.next].prev = node.prev;
        } else {
            list.tail = node.prev;
        }

        delete list.nodes[data];
        list.size--;
    }

    // Function to get the size of the list
    function getSize() internal view returns (uint256) {
        return list.size;
    }

    function contains(address data) internal view returns (bool) {
        return list.nodes[data].data != address(0);
    }

    function getAllItems() internal view returns (address[] memory) {
        address[] memory items = new address[](list.size);
        address current = list.head;
        for (uint256 i = 0; i < list.size; i++) {
            items[i] = current;
            current = list.nodes[current].next;
        }
        return items;
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

library LibRoles {

    bytes32 constant public ROLE_OWNER = keccak256("ROLE_OWNER");
    bytes32 constant public ROLE_ADMIN = keccak256("ROLE_ADMIN");
    bytes32 constant public ROLE_SIGNER = keccak256("ROLE_SIGNER");
    bytes32 constant public ROLE_VECTOR_AUTHORITY = keccak256("ROLE_VECTOR_AUTHORITY");
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * @title IAccessControl
 * @dev The IAccessControl is the interface for managing roles and signers.
 */
interface IAccessControl {

    event RoleChanged(bytes32 indexed role, address indexed account, bool indexed grant);
    event SignerChanged(address signer, bool grant);
    event OwnerChanged(address indexed owner, address indexed newOwner);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function addSigners(address[] calldata signers) external;
    function removeSigners(address[] calldata signers) external;
    function isSigner(address account) external view returns (bool);
    function isAdmin(address account) external view returns (bool);
    function owner() external view returns (address);
    function changeOwner(address newOwner) external;
}
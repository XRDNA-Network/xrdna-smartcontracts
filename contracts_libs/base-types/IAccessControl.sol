// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IAccessControl {

    function owner() external view returns (address);
    
    function addSigners(address[] calldata signers) external;

    function removeSigners(address[] calldata signers) external;

    function isSigner(address a) external view returns (bool);

    function setOwner(address o) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

}
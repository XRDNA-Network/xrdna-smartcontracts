// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface ISupportsAccess {
    
        function hasRole(bytes32 role, address account) external view returns (bool);
    
        function grantRole(bytes32 role, address account) external;
    
        function revokeRole(bytes32 role, address account) external;
}
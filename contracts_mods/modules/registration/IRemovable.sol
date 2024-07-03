// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IRemovable {

    event EntityDeactivated(address indexed by, string reason);
    event EntityReactivated(address indexed by);
    event EntityRemoved(address indexed by, string reason);

    function deactivate(string memory reason) external;
    function reactivate() external;
    function remove(string memory reason) external;
    function isEntityActive() external view returns (bool);
    function isRemoved() external view returns (bool);
}
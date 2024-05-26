// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


interface IRegistrarRegistry {
    function isRegistrar(uint256 id, address account) external view returns (bool);
    function register(address payable signer) external payable;
    function addSigners(uint256 registrarId, address[] memory signers) external;
    function removeSigners(uint256 registrarId, address[] memory signers) external;
}
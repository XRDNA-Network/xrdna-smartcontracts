// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


interface IBasicCompany {
    function getName() external view returns (string memory);
    function getOwner() external view returns (address);
    function isSigner(address signer) external view returns (bool);
    function upgrade(address newCompany) external;
    function init(address owner, bytes calldata initData) external;

}


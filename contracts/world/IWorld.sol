// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import { VectorAddress } from "../VectorAddress.sol";

interface IBasicWorld {
    function getOwner() external view returns (address);
    function getBaseVector() external view returns (VectorAddress memory);
    function getName() external view returns (string memory);
    function init(address owner, bytes calldata initData) external;
    function upgrade(address newWorld) external;
}

interface IWorld is IBasicWorld {
    function addSigners(address[] memory sigs) external;
    function removeSigners(address[] memory sigs) external;
}
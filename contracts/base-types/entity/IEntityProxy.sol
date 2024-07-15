// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from '../../libraries/LibVersion.sol';

/**
    * @title IEntityProxy
    * @dev Interface for entity proxy contracts
 */
interface IEntityProxy {
    function setImplementation(address _implementation) external;

    function getImplementation() external view returns (address);

    function getVersion() external view returns (Version memory);
}
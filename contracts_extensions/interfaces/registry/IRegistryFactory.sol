// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from '../../libraries/LibTypes.sol';

interface IRegistryFactory {

    function setEntityImplementation(address _entityImplementation) external;
    function getEntityImplementation() external view returns (address);
    function getEntityVersion() external view returns (Version memory);
}
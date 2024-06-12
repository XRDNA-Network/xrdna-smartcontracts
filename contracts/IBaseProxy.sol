// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IBaseAccess} from './IBaseAccess.sol';

interface IBaseProxy is IBaseAccess {

    
    event ImplementationChanged (address indexed implementation);
    
    function initProxy(address _implementation) external;
    function getImplementation() external view returns (address);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {IBaseAccess} from './IBaseAccess.sol';

/**
 * @title IBaseProxy
 * @dev Interface for the base proxy contract.
 */
interface IBaseProxy is IBaseAccess {

    
    event ImplementationChanged (address indexed implementation);
    
    /**
     * @dev Initializes the proxy with the implementation address.
     */
    function initProxy(address _implementation) external;

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() external view returns (address);
}
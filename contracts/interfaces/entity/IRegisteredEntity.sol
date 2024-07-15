// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {Version} from '../../libraries/LibVersion.sol';


/**
 * @title IRegisteredEntity
 * @dev The IRegisteredEntity contract is the base interface for all registered entities (Worlds, 
 * Companies, Experiences, etc.). It provides a name and version for the entity.
 */
interface IRegisteredEntity {

    /**
     * @dev Returns the name of the entity.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the version of the entity.
     */
    function version() external view returns (Version memory);

    /**
     * @dev Upgrades the entity to the latest version of the entity logic, if applicable.
     */
    function upgrade() external;
}
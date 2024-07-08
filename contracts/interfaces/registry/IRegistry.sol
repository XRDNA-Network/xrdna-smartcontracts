// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAccessControl} from '../IAccessControl.sol';
import {IEntityRemoval} from './IEntityRemoval.sol';
import {Version} from '../../libraries/LibTypes.sol';

interface IRegistry is IAccessControl {


    event RegistryAddedEntity(address indexed entity, address indexed owner);
    

    //to create registered entities
    function setEntityImplementation(address implementation) external;
    function getEntityImplementation() external view returns (address);
    function getEntityVersion() external view returns (Version memory);

    function isRegistered(address addr) external view returns (bool);
    function getEntityByName(string calldata name) external view returns (address);
    

}
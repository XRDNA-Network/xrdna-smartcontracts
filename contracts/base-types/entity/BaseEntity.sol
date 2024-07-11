// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseAccess} from '../BaseAccess.sol';
import {IRegisteredEntity} from '../../interfaces/entity/IRegisteredEntity.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';

/**
 * @title BaseEntity
 * @dev Base contract for all (non-registry) entity types
 */
abstract contract BaseEntity is BaseAccess, IRegisteredEntity {

    modifier onlyRegistry {
        require(msg.sender == owningRegistry(), 'RemovableEntity: only owning registry');
        _;
    }

    modifier onlySigner {
        require(isSigner(msg.sender), 'Entity: only signers');
        _;
    }

    //all entity types can receive tokens
    receive() external payable {}

    /**
        * @dev Returns the address of the registry that owns this entity
     */
    function owningRegistry() internal view virtual returns (address);

    
    /**
     * @dev Returns the name of the entity
     */
    function name() external view returns (string memory) {
        return LibEntity.load().name;
    }
    
}
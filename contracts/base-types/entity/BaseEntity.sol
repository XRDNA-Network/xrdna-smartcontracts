// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseAccess} from '../BaseAccess.sol';
import {IRegisteredEntity} from '../../interfaces/entity/IRegisteredEntity.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';

abstract contract BaseEntity is BaseAccess, IRegisteredEntity {

    modifier onlyRegistry {
        require(msg.sender == owningRegistry(), 'RemovableEntity: only owning registry');
        _;
    }

    function owningRegistry() internal view virtual returns (address);

    modifier onlySigner {
        require(isSigner(msg.sender), 'Entity: only signers');
        _;
    }

    receive() external payable {}

    function name() external view returns (string memory) {
        return LibEntity.load().name;
    }
    
}
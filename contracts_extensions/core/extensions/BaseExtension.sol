// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibExtensions} from '../LibExtensions.sol';
import {LibAccess} from '../LibAccess.sol';
import {IExtension} from './IExtension.sol';
import {LibRoles} from '../LibRoles.sol';

abstract contract BaseExtension is IExtension {

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "BaseExtension: not owner");
        _;
    }

    modifier onlyAdmin {
        require(
            LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender) ||
            LibAccess.owner() == msg.sender,
            "BaseExtension: not admin");
        _;
    }

    function hasRole(bytes32 role, address account) public view returns (bool){
        return LibAccess.hasRole(role, account);
    }

}
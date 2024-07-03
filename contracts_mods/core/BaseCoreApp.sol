// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreApp} from './ICoreApp.sol';
import {LibAccess} from '../libraries/LibAccess.sol';
import {IModuleRegistry} from './IModuleRegistry.sol';
import {LibRoles} from '../libraries/LibRoles.sol';
import {ILoopback} from './ILoopback.sol';

abstract contract BaseCoreApp is ILoopback, ICoreApp {

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "BaseCoreApp: caller is not an admin");
        _;
    }

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "BaseCoreApp: caller is not the owner");
        _;
    }

    modifier onlySigner {
        require(LibAccess.hasRole(LibRoles.ROLE_SIGNER, msg.sender), "BaseCoreApp: caller is not a signer");
        _;
    }

    modifier onlySelf {
        require(msg.sender == address(this), "BaseCoreApp: only self allowed");
        _;
    }

    receive() external payable {}

    function staticLoop(address tgt, bytes memory data) external onlySelf returns (bytes memory) {
        
        assembly {
            let success := delegatecall(gas(), tgt, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch success
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }


    function owner() external view returns (address) {
        return LibAccess.owner();
    }

    function addSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.addSigners(signers);
    }

    function removeSigners(address[] calldata signers) external onlyAdmin {
        LibAccess.removeSigners(signers);
    }

    function isSigner(address a) external view returns (bool) {
        return LibAccess.isSigner(a);
    }

    function setOwner(address o) external onlyOwner {
        LibAccess.setOwner(o);
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        return LibAccess.hasRole(role, account);
    }

    function grantRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyAdmin {
        LibAccess.revokeRole(role, account);
    }
}
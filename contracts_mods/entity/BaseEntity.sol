// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegisteredEntity} from '../modules/registration/IRegisteredEntity.sol';
import {LibAccess} from '../libraries/LibAccess.sol';
import {ModuleVersion} from '../modules/IModule.sol';
import {IRegistry} from '../modules/registry/IRegistry.sol';
import {LibRoles} from '../libraries/LibRoles.sol';
import {IEntityFactory} from '../modules/entity/factory/IEntityFactory.sol';


struct BaseEntityConstructorArgs {
    IRegistry owningRegistry;
}

abstract contract BaseEntity is IRegisteredEntity {

    IRegistry public immutable owningRegistry;

    modifier onlyRegistry() {
        require(msg.sender == address(owningRegistry), "BaseEntity: caller is not the owning registry");
        _;
    }

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "BaseEntity: caller is not an admin");
        _;
    }

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "BaseEntity: caller is not the owner");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "BaseEntity: caller is not a signer");
        _;
    }

    constructor(BaseEntityConstructorArgs memory args) {
        require(address(args.owningRegistry) != address(0), "BaseEntity: owning registry cannot be zero address");  
        owningRegistry = args.owningRegistry;
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
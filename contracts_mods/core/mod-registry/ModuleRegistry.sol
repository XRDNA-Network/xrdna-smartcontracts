// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ModuleReference} from '../IModuleRegistry.sol';
import {IModuleRegistryWithAccess} from '../IModuleRegistryWithAccess.sol';
import {ModuleVersion, IModule} from '../../modules/IModule.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {LibStringCase} from '../../libraries/LibStringCase.sol';
import {LibVersion} from '../../libraries/LibVersion.sol';

struct ModuleRegistryConstructorArgs {
    address owner;
    address[] admins;
}

contract ModuleRegistry is IModuleRegistryWithAccess, AccessControl {

    using LibStringCase for string;
    using LibVersion for ModuleVersion;

    address public owner;
    mapping(string => ModuleReference) modules;

    modifier onlyAdmin {
        require(hasRole(LibRoles.ROLE_ADMIN, msg.sender), "ModuleRegistry: caller is not an admin");
        _;
    }

    constructor(ModuleRegistryConstructorArgs memory args) {
        require(args.owner != address(0), "ModuleRegistry: owner cannot be zero address");
        owner = args.owner;
        _grantRole(LibRoles.ROLE_ADMIN, args.owner);
        _grantRole(LibRoles.ROLE_OWNER, args.owner);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), "ModuleRegistry: admin cannot be zero address");
            _grantRole(LibRoles.ROLE_ADMIN, args.admins[i]);
        }
    }

    function hasCode(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function isOwner(address account) external view returns (bool) {
        return owner == account;
    }

    function get(string calldata name) external view returns (ModuleReference memory) {
        return modules[name.lower()];
    }

    function getVersion(string calldata name) external view returns (ModuleVersion memory) {
        return modules[name.lower()].version;
    }

    function put(IModule mod) external onlyAdmin {
        require(hasCode(address(mod)), "ModuleRegistry: module has no code");
        
        string memory name = mod.name().lower();
        require(modules[name].module == address(0), "ModuleRegistry: module already exists");
        modules[name] = ModuleReference(true, address(mod), mod.version());
        emit ModuleAdded(address(mod), mod.version().major, mod.version().minor, name);
    }


    function upgrade(IModule mod) external onlyAdmin {
        require(hasCode(address(mod)), "ModuleRegistry: module has no code");

        string memory name = mod.name().lower();
        ModuleVersion memory nv = mod.version();

        ModuleReference storage ref = modules[name];
        require(ref.module != address(0), "ModuleRegistry: module does not exist");
        require(nv.greaterThan(ref.version), "VersionControl: new version must be greater");
        modules[name] = ModuleReference(true, address(mod), nv);
        emit ModuleUpgraded(address(mod), nv.major, nv.minor, name);
    }

    function rollback(IModule mod) external onlyAdmin {
        require(hasCode(address(mod)), "ModuleRegistry: module has no code");
        
        string memory name = mod.name().lower();
        ModuleVersion memory nv = mod.version();

        ModuleReference storage ref = modules[name];
        require(ref.module != address(0), "ModuleRegistry: module does not exist");

        require(nv.lessThan(ref.version), "VersionControl: new version must be less than current");
        modules[name] = ModuleReference(true, address(mod), mod.version());
        emit ModuleRolledBack(address(mod), nv.major,  nv.minor, name);
    }

    function disable(string calldata name) external onlyAdmin {
        ModuleReference storage ref = modules[name.lower()];
        require(ref.module != address(0), "ModuleRegistry: module does not exist");
        ref.enabled = false;
        emit ModuleDisabled(name);
    }

    function enable(string calldata name) external onlyAdmin {
        ModuleReference storage ref = modules[name.lower()];
        require(ref.module != address(0), "ModuleRegistry: module does not exist");
        ref.enabled = true;
        emit ModuleEnabled(name);
    }

}
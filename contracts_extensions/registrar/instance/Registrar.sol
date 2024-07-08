// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityShell} from '../../base-types/EntityShell.sol';
import {IExtensionResolver} from '../../interfaces/IExtensionResolver.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {CommonInitArgs} from '../../interfaces/entity/IRegisteredEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';

struct RegistrarConstructorArgs {
    address extensionResolver;
    address owningRegistry;
    address worldRegistry;
}

contract Registrar  is EntityShell {
    
    IRegistrarRegistry public immutable registrarRegistry;
    IWorldRegistry public immutable worldRegistry;

    modifier onlyRegistry {
        require(msg.sender == address(registrarRegistry), "Registrar: only registrar registry");
        _;
    }

    constructor(RegistrarConstructorArgs memory args) EntityShell(IExtensionResolver(args.extensionResolver)) {
        
        require(args.owningRegistry != address(0), "Registrar: owningRegistry cannot be zero address");
        require(args.worldRegistry != address(0), "Registrar: worldRegistry cannot be zero address");
        registrarRegistry = IRegistrarRegistry(args.owningRegistry);
        worldRegistry = IWorldRegistry(args.worldRegistry);
       
    }

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
    }

    function name() external view returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function init(CommonInitArgs memory args) external onlyRegistry {
        require(bytes(args.name).length > 0, "LibRegistrar: name cannot be empty");
        require(args.termsOwner != address(0), "LibRegistrar: terms owner cannot be zero address");

        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
        rs.termsOwner = args.termsOwner;
    }

}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityShell} from '../../base-types/EntityShell.sol';
import {IExtensionResolver} from '../../interfaces/IExtensionResolver.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {CommonInitArgs} from '../../interfaces/entity/IRegisteredEntity.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibVectorAddress, VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';

struct WorldConstructorArgs {
    address extensionResolver;
    address owningRegistry;
    address registrarRegistry;
    address companyRegistry;
}

contract World  is EntityShell {
    
    using LibVectorAddress for VectorAddress;

    IWorldRegistry public immutable worldRegistry;
    IRegistrarRegistry public immutable registrarRegistry;
    address public immutable companyRegistry;

    modifier onlyRegistry {
        require(msg.sender == address(worldRegistry), "World: only world registry");
        _;
    }

    constructor(WorldConstructorArgs memory args) EntityShell(IExtensionResolver(args.extensionResolver)) {
        
        require(args.owningRegistry != address(0), "World: owningRegistry cannot be zero address");
        require(args.registrarRegistry != address(0), "World: registrarRegistry cannot be zero address");
        require(args.companyRegistry != address(0), "World: companyRegistry cannot be zero address");
        registrarRegistry = IRegistrarRegistry(args.registrarRegistry);
        worldRegistry = IWorldRegistry(args.owningRegistry);        
        companyRegistry = args.companyRegistry;
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

    function init(CommonInitArgs calldata args) external onlyRegistry {
        require(args.termsOwner != address(0), "World: terms owner is the zero address");
        require(bytes(args.name).length > 0, "World: name cannot be empty");

        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);

        args.vector.validate(false, false);
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
        rs.vector = args.vector;
        rs.termsOwner = args.termsOwner;
    }

    function baseVector() external view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }
}
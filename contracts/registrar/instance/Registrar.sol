// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {IRegistrar, NewWorldArgs} from './IRegistrar.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IWorldRegistry, CreateWorldArgs} from '../../world/registry/IWorldRegistry.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';

struct RegistrarConstructorArgs {
    address registrarRegistry;
    address worldRegistry;
}

contract Registrar is BaseRemovableEntity, IRegistrar {

    address public immutable registrarRegistry;
    IWorldRegistry public immutable worldRegistry;

    constructor(RegistrarConstructorArgs memory args) {
        require(args.registrarRegistry != address(0), 'Registrar: Invalid registrar registry');
        require(args.worldRegistry != address(0), 'Registrar: Invalid world registry');
        registrarRegistry = args.registrarRegistry;
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function owningRegistry() internal view override returns (address) {
        return registrarRegistry;
    }

    function init(string calldata name, address owner, bytes calldata) external onlyRegistry {
        LibEntity.load().name = name;
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = msg.sender;
        address[] memory admins = new address[](0);
        LibAccess.initAccess(owner, admins);
    }


    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(NewWorldArgs memory args) external payable  onlySigner  returns (address world){
        world = worldRegistry.createWorld(CreateWorldArgs({
            sendTokensToOwner: args.sendTokensToOwner,
            owner: args.owner,
            name: args.name,
            terms: args.terms,
            initData: args.initData,
            ownerTermsSignature: args.ownerTermsSignature,
            expiration: args.expiration,
            vector: args.baseVector,
            vectorAuthoritySignature: args.vectorAuthoritySignature
        }));
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(world).transfer(msg.value);
            }
        }
    }

    function deactivateWorld(address world, string calldata reason) external onlySigner {
        worldRegistry.deactivateEntity(IRemovableEntity(world), reason);
    }

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external onlySigner {
        worldRegistry.reactivateEntity(IRemovableEntity(world));
    }

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world, string calldata reason) external onlySigner {
        worldRegistry.removeEntity(IRemovableEntity(world), reason);
    }


    function isStillActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isTermsOwnerSigner(address a) external view returns (bool) {
        return isSigner(a);
    }
}
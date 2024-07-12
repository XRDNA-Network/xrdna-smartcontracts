// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {IRegistrar, NewWorldArgs} from './IRegistrar.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {IWorldRegistry, CreateWorldArgs} from '../../world/registry/IWorldRegistry.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';

struct RegistrarConstructorArgs {
    address registrarRegistry;
    address worldRegistry;
}

/**
 * @title Registrar
 * @dev Registrar is an entity that creates and manages worlds. This implementation logic is applied
 * to the registrar proxy, which is cloned for each new registrar instance.
 */
contract Registrar is BaseRemovableEntity, IRegistrar {

    address public immutable registrarRegistry;
    IWorldRegistry public immutable worldRegistry;

    //initialized once to establish immutable registry addresses for all uses of implementation logic.
    constructor(RegistrarConstructorArgs memory args) {
        require(args.registrarRegistry != address(0), 'Registrar: Invalid registrar registry');
        require(args.worldRegistry != address(0), 'Registrar: Invalid world registry');
        registrarRegistry = args.registrarRegistry;
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    receive() external payable {}

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function owningRegistry() internal view override returns (address) {
        return registrarRegistry;
    }

    /**
     * @dev Initializes the registrar. Must be called by the registry during registration
     */
    function init(string calldata _name, address _owner, bytes calldata) external onlyRegistry {
       require(bytes(_name).length > 0, "Registrar: name required");
       LibEntity.load().name = _name;
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        //the registry itself is the terms authority for a registrar
        rs.termsOwner = msg.sender;
        address[] memory admins = new address[](0);
        LibAccess.initAccess(_owner, admins);
    }


    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(NewWorldArgs memory args) external payable  onlySigner nonReentrant  returns (address world){
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
        require(world != address(0), "Registrar: world creation failed");
        //transfer any attached tokens
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(world).transfer(msg.value);
            }
        }
    }

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world, string calldata reason) external onlySigner nonReentrant {
        worldRegistry.deactivateEntity(IRemovableEntity(world), reason);
    }

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external onlySigner nonReentrant {
        worldRegistry.reactivateEntity(IRemovableEntity(world));
    }

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world, string calldata reason) external onlySigner nonReentrant {
        worldRegistry.removeEntity(IRemovableEntity(world), reason);
    }


    /**
     * @dev Returns whether the registrar is still active
     */
    function isStillActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    /**
     * @dev Returns whether the given address is a signer for the registrar
     */
    function isTermsOwnerSigner(address a) external view returns (bool) {
        return isSigner(a);
    }

    function withdraw(uint256 amount) external override onlyOwner {
        require(amount <= address(this).balance, "Registrar: insufficient balance");
        payable(owner()).transfer(amount);
    }

    
}
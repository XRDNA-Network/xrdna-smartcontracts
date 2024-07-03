// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistrar, NewWorldArgs} from "../interfaces/IRegistrar.sol";
import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {BaseEntityConstructorArgs} from "../../base-types/entity/BaseEntity.sol";
import {Version} from "../../core-libs/LibTypes.sol";
import {LibAccess} from '../../core-libs/LibAccess.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {LibFundable} from '../../core-libs/LibFundable.sol';
import {LibRegistrar} from '../libs/LibRegistrar.sol';
import {LibRemovableEntity} from '../../entity-libs/removal/LibRemovableEntity.sol';
import {IRegistrarRegistry} from '../interfaces/IRegistrarRegistry.sol';
import {IWorldRegistry, CreateWorldArgs} from '../../world/interfaces/IWorldRegistry.sol';
import {IRemovableEntity} from '../../entity-libs/interfaces/IRemovableEntity.sol';
import {CommonInitArgs} from '../../entity-libs/interfaces/IRegisteredEntity.sol';
import {VectorAddress} from '../../core-libs/LibVectorAddress.sol';

struct RegistrarConstructorArgs {
    address owningRegistry;
    address worldRegistry;
}
contract Registrar is BaseRemovableEntity, IRegistrar {

    IWorldRegistry public immutable worldRegistry;
    

    constructor(RegistrarConstructorArgs memory args) BaseRemovableEntity(BaseEntityConstructorArgs({
        owningRegistry: args.owningRegistry
    })) {
        require(args.worldRegistry != address(0), "Registrar: world registry cannot be zero address");
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    function name() external view override returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function termsOwner() external view override returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function init(CommonInitArgs memory args) public override {
        LibRegistrar.init(args);
    }

    function upgrade(bytes calldata data) external override onlyAdmin {
        IRegistrarRegistry(owningRegistry).upgradeEntity(data);
    }

    function postUpgradeInit(bytes calldata data) external override onlyAdmin {
       //no-op until future version available
    }

    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(NewWorldArgs memory args) external payable onlySigner returns (address)  {
        
        address a = LibRegistrar.registerWorld(worldRegistry, args);
        require(a != address(0), "Registrar: world registry returned zero address");
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(a).transfer(msg.value);
            }
        }
        emit RegistrarAddedWorld(a, args.owner);
        return a;
    }

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world, string calldata reason) external onlySigner {
        worldRegistry.deactivateEntity(IRemovableEntity(world), reason);
        emit RegistrarDeactivatedWorld(world, reason);
    }

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external onlySigner {
        worldRegistry.reactivateEntity(IRemovableEntity(world));
        emit RegistrarReactivatedWorld(world);
    }

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world, string calldata reason) external onlySigner {
        worldRegistry.removeEntity(IRemovableEntity(world), reason);
        emit RegistrarRemovedWorld(world, reason);
    }

    function isStillActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isTermsOwnerSigner(address a) external view returns (bool) {
        return LibAccess.isSigner(a);
    }

    function withdraw(uint256 amount) external override onlyOwner {
        LibFundable.withdraw(amount);
    }
}
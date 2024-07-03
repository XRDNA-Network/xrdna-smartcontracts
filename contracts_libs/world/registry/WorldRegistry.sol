// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {IWorldRegistry, CreateWorldArgs} from '../interfaces/IWorldRegistry.sol';
import {Version, RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {LibTermsOwner} from '../../core-libs/LibTermsOwner.sol';
import {LibAccess} from '../../core-libs/LibAccess.sol';
import {LibRoles} from '../../core-libs/LibRoles.sol';
import {VectorAddress, LibVectorAddress} from '../../core-libs/LibVectorAddress.sol';
import {IRegistry, CreateEntityArgs} from '../../base-types/registry/IRegistry.sol';
import {IRemovableEntity} from '../../entity-libs/interfaces/IRemovableEntity.sol';
import {LibRegistry, RegistrationRequest} from '../../core-libs/LibRegistry.sol';
import {LibEntityRemoval} from '../../entity-libs/removal/LibEntityRemoval.sol';
import {IWorld} from '../interfaces/IWorld.sol';
import {CommonInitArgs} from '../../entity-libs/interfaces/IRegisteredEntity.sol';
import {LibControlChange} from '../../entity-libs/control-change/LibControlChange.sol';
import {ChangeControllerArgs} from '../../entity-libs/interfaces/IControlChange.sol';
import {LibRegistration, TermsSignatureVerification} from '../../entity-libs/registration/LibRegistration.sol';

struct WorldRegistryConstructorArgs {
    address registrarRegistry;
}

contract WorldRegistry is BaseRegistry, IWorldRegistry {

    using LibVectorAddress for VectorAddress;

    IRegistry public immutable registrarRegistry;

    modifier onlyRegistrar {
        require(registrarRegistry.isRegistered(msg.sender) && 
                IRemovableEntity(msg.sender).isEntityActive(), "WorldRegistry: caller is not the registrar registry");
        _;
    }

    modifier onlyOwningRegistrar(address world) {
        require(registrarRegistry.isRegistered(msg.sender) && 
                IRemovableEntity(msg.sender).isEntityActive() && 
                IWorld(world).termsOwner() == msg.sender, "WorldRegistry: caller is not the actively registered owning company of world");
        _;
    }

    constructor(WorldRegistryConstructorArgs memory args) BaseRegistry() {
        require(args.registrarRegistry != address(0), "WorldRegistry: registrar registry cannot be zero address");
        registrarRegistry = IRegistry(args.registrarRegistry);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function createWorld(CreateWorldArgs calldata args) external override onlyRegistrar returns (address) {
        require(args.terms.gracePeriodDays > 0, "RegistrarRegistry: world terms grace period must be greater than 0");
        LibRegistration.verifyNewEntityTermsSignature(TermsSignatureVerification({
            owner: args.owner,
            terms: args.terms,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        }));

        address signer = args.baseVector.getSigner(msg.sender, args.vectorAuthoritySignature);
        require(LibAccess.hasRole(LibRoles.ROLE_VECTOR_AUTHORITY, signer), "WorldRegistry: vector signer is not a valid vector address authority");

        require(bytes(args.baseVector.x).length != 0, "WorldRegistry: baseVector.x cannot be zero");
        require(bytes(args.baseVector.y).length != 0, "WorldRegistry: baseVector.y cannot be zero");
        require(bytes(args.baseVector.z).length != 0, "WorldRegistry: baseVector.z cannot be zero");
        require(args.baseVector.p == 0, "WorldRegistry: baseVector.p must be zero");
        require(args.baseVector.p_sub == 0, "WorldRegistry: baseVector.p_sub must be zero");

        CommonInitArgs memory initArgs = CommonInitArgs({
            owner: args.owner,
            name: args.name,
            termsOwner: msg.sender,
            initData: args.initData,
            vector: args.baseVector
        });
        RegistrationRequest memory req = RegistrationRequest({
            terms: args.terms,
            initData: initArgs
        });

        address a = LibRegistry.registerRemovable(req);

        
        emit RegistryAddedEntity(a, args.owner);
        return a;
    }

    function addVectorAddressAuthority(address authority) external onlyAdmin {
        require(authority != address(0), "WorldRegistry: authority cannot be zero address");
        LibAccess.grantRole(LibRoles.ROLE_VECTOR_AUTHORITY, authority);
    }

    function removeVectorAddressAuthority(address authority) external onlyAdmin {
        require(authority != address(0), "WorldRegistry: authority cannot be zero address");
        LibAccess.revokeRole(LibRoles.ROLE_VECTOR_AUTHORITY, authority);
    }

    function isVectorAddressAuthority(address a) external view override returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_VECTOR_AUTHORITY, a);
    }


    /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) external onlyOwningRegistrar(address(entity)) {
        LibEntityRemoval.deactivateEntity(entity, reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) external onlyOwningRegistrar(address(entity)) {
        LibEntityRemoval.reactivateEntity(entity);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external onlyOwningRegistrar(address(entity)) {
        LibEntityRemoval.removeEntity(entity, reason);
    }

    function changeWorldRegistrar(ChangeControllerArgs calldata args) external override onlyRegistrar {
        require(isRegistered(args.entity), "WorldRegistry: entity is not registered");
        IWorld w = IWorld(args.entity);
        require(w.isEntityActive(), "WorldRegistry: entity is not active");
        LibControlChange.changeControllerWithTerms(args);
        w.changeTermsOwner(msg.sender);
        emit RegistryChangedTermsController(args.entity, msg.sender);
    }

}
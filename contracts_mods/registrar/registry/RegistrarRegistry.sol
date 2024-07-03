// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibModule} from "../../core/LibModule.sol";
import {IModuleRegistry} from "../../core/IModuleRegistry.sol";
import {LibAccess} from "../../libraries/LibAccess.sol";
import {LibRoles} from "../../libraries/LibRoles.sol";
import {ICoreApp} from "../../core/ICoreApp.sol";
import {ModuleVersion} from "../../modules/IModule.sol";
import {IRegistrarRegistry, CreateRegistrarArgs} from "./IRegistrarRegistry.sol";
import {
    IRegistration,
    RegistrationTerms,
    ChangeEntityTermsArgs
} from "../../modules/registration/IRegistration.sol";
import {IRegistrar} from '../instance/IRegistrar.sol';
import {IRemovableEntity, IEntityRemoval} from "../../modules/entity/removal/IEntityRemoval.sol";
import {BaseCoreApp} from "../../core/BaseCoreApp.sol";
import {LibEntityRemoval} from "../../libraries/registry/LibEntityRemoval.sol";
import {IEntityFactory} from "../../modules/entity/factory/IEntityFactory.sol";
import {LibRegistration} from "../../libraries/registry/LibRegistration.sol";
import {LibTermsOwner} from "../../libraries/LibTermsOwner.sol";
import {LibRegistry, RegistryStorage} from "../../libraries/LibRegistry.sol";
import {IEntityProxy} from '../../entity/IEntityProxy.sol';
import {LibVersion} from '../../libraries/LibVersion.sol';
import "hardhat/console.sol";

contract RegistrarRegistry is BaseCoreApp, IRegistrarRegistry {


    using LibVersion for ModuleVersion;
    
    string public constant override name = 'RegistrarRegistry';

    modifier onlyRegistrar {
        require(isRegistered(msg.sender) && IRegistrar(msg.sender).isStillActive(), "RegistrarRegistry: caller is not a registered entity");
        _;
    }

    function setEntityRemovalLogic(address removalModule) external onlyAdmin {
        require(removalModule != address(0), "RegistrarRegistry: removal module cannot be zero address");
        LibRegistry.load().removalLogic = removalModule;
    }

    function entityRemovalLogic() external view returns (address) {
        return LibRegistry.load().removalLogic;
    }

    function setEntityFactory(address factory) external onlyAdmin {
        require(factory != address(0), "RegistrarRegistry: factory cannot be zero address");
        LibRegistry.load().entityFactory = factory;
    }

    function entityFactory() external view returns (address) {
        return LibRegistry.load().entityFactory;
    }

    function setRegistrationLogic(address registration) external onlyAdmin {
        require(registration != address(0), "RegistrarRegistry: registration module cannot be zero address");
        LibRegistry.load().registrationLogic = registration;
    }

    function registrationLogic() external view returns (address) {
        address rl = LibRegistry.load().registrationLogic;
        console.log("RegistrarRegistry: registrationLogic", rl);
        return rl;
    }

    function version() external pure override(ICoreApp, IRegistrarRegistry) returns (ModuleVersion memory) {
        return ModuleVersion(1, 0);
    }

    function isRegistered(address addr) public view returns (bool)  {
        return LibRegistration.isRegistered(addr);
    }

    function getEntityByName(string calldata nm) external view returns (address) {
        return LibRegistration.getEntityByName(nm);
    }

    function getEntityTerms(address addr) external view returns (RegistrationTerms memory) {
        return LibEntityRemoval.getEntityTerms(addr);
    }

    function getTerms() external view returns (RegistrationTerms memory) {
        return LibTermsOwner.load().terms;
    }

    function setTerms(RegistrationTerms calldata terms) external onlyOwner {
        LibTermsOwner.load().terms = terms;
    }

    function isStillActive() external pure returns (bool) {
        return true; //registry always active
    }

    function isTermsOwnerSigner(address a) external view returns (bool) {
        return LibAccess.isSigner(a);
    }
    
    /** 
      @dev Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
      * mallicious activity. The entity can be reactivated by the terms owner.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) external onlySigner {
        LibEntityRemoval.deactivateEntity(entity, reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) external onlySigner {
        LibEntityRemoval.reactivateEntity(entity);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external onlySigner {
        LibEntityRemoval.removeEntity(entity, reason);
    }

    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external onlySigner {
        LibRegistration.changeEntityTerms(args);
    }

    /**
     * @dev Returns whether an entity can be deactivated. Entities can only be deactivated
     * if they are either expired or within the grace period
     */
    function canBeDeactivated(address addr) external view returns (bool) {
        return LibEntityRemoval.canBeDeactivated(addr);
    }

    /**
     * @dev Returns whether an entity can be removed. Entities can only be removed if they are
     * outside the grace period
     */
    function canBeRemoved(address addr) external view returns (bool) {
        return LibEntityRemoval.canBeRemoved(addr);
    }

    /**
     * @dev Enforces deactivation of an entity. Can be called by anyone but will only
     * succeed if the entity is inside the grace period
     */
    function enforceDeactivation(IRemovableEntity addr) external {
        LibEntityRemoval.enforceDeactivation(addr);
    }

    /**
     * @dev Enforces removal of an entity. Can be called by anyone but will only
     * succeed if it is outside the grace period
     */
    function enforceRemoval(IRemovableEntity e) external {
        LibEntityRemoval.enforceRemoval(e);
    }


    /**
     * @dev Returns the last renewal timestamp in seconds for the given address.
     */
    function getLastRenewal(address addr) external view returns (uint256) {
        return LibEntityRemoval.getLastRenewal(addr);
    }

    /**
     * @dev Returns the expiration timestamp in seconds for the given address.
     */
    function getExpiration(address addr) external view returns (uint256) {
        return LibEntityRemoval.getExpiration(addr);
    }

    /**
     * @dev Check whether an address is expired.
     */
    function isExpired(address addr) external view returns (bool) {
        return LibEntityRemoval.isExpired(addr);
    }

    /**
     * @dev Check whether an address is in the grace period.
     */
    function isInGracePeriod(address addr) external view returns (bool) {
        return LibEntityRemoval.isInGracePeriod(addr);
    }

    /**
     * @dev Renew an entity by paying the renewal fee.
     */
    function renewEntity(address addr) external payable {
        LibEntityRemoval.renewEntity(addr);
    }

    function createRegistrar(CreateRegistrarArgs calldata args) external payable onlySigner returns (address)  {
        console.log("RegistrarRegistry: createRegistrar");
        IEntityFactory ef = IEntityFactory(LibRegistry.load().entityFactory);
        address a = ef.createEntity(args.owner, args.name, args.initData);
        require(a != address(0), "RegistrarRegistry: entity creation failed");

        IEntityProxy(a).setImplementation(ef.getEntityImplementation());
        IRegistrar(a).init(args.owner, args.name, args.initData);

        LibRegistration.registerEntityWithTerms(a, LibTermsOwner.load().terms);
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(a).transfer(msg.value);
            }
        }
        return a;
    }

    function upgradeEntity(bytes calldata data) external onlyRegistrar {
        IEntityFactory ef = IEntityFactory(LibRegistry.load().entityFactory);
        ModuleVersion memory v = ef.version();
        IRegistrar r = IRegistrar(msg.sender);
        require(v.lessThan(r.version()), "RegistrarFactory: entity version is up to date");
        IEntityProxy(msg.sender).setImplementation(ef.getEntityImplementation());
        r.postUpgradeInit(data);
    }
}
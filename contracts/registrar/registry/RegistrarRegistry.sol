// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {LibAccess } from '../../libraries/LibAccess.sol';
import {IRegistrarRegistry, CreateNonRemovableRegistrarArgs, CreateRegistrarArgs} from './IRegistrarRegistry.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {IRegistrar} from '../instance/IRegistrar.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {IEntityProxy} from '../../base-types/entity/IEntityProxy.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {ChangeEntityTermsArgs, IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';
import {IEntityRemoval} from '../../interfaces/registry/IEntityRemoval.sol';


/**
 * @title RegistrarRegistry
    * @dev RegistrarRegistry is a registry that creates and manages registrars. It is the terms authority for all registrars.
 */
contract RegistrarRegistry is BaseRemovableRegistry, IRegistrarRegistry {

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "RegistrarRegistry: caller is not a signer");
        _;
    }

    function version() external pure override returns(Version memory) {
        return Version(1, 0);
    }


    receive() external payable {}
    
    /**
     * @inheritdoc IRegistrarRegistry
     */
    function createNonRemovableRegistrar(CreateNonRemovableRegistrarArgs calldata args) external payable onlySigner nonReentrant returns (address) {
        FactoryStorage storage fs = LibFactory.load();
        
        //make sure proxy and logic have been set
        require(fs.proxyImplementation != address(0), "RegistrarRegistration: proxy implementation not set");
        require(fs.entityImplementation != address(0), "RegistrarRegistry: entity implementation not set");
        
        //clone the registrar proxy
        address proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "RegistrarRegistration: entity cloning failed");

        //and set the impl logic on the new proxy address
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        //initialize registrar state
        IRegistrar(proxy).init(args.name, args.owner, args.initData);

        //register non-removable
        _registerNonRemovableEntity(proxy);

        //transfer tokens if applicable
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(proxy).transfer(msg.value);
            }
        }

        emit RegistryAddedEntity(proxy, args.owner);

        return proxy;
    }

    /**
     * @inheritdoc IRegistrarRegistry
     */
    function createRemovableRegistrar(CreateRegistrarArgs calldata args) external payable onlySigner nonReentrant returns (address proxy) {
        
        //and that there is a grace period, if even terms have 0 coverage period. This gives Registrar
        //opportunity to correct any issues with the terms before being removed.
        require(args.terms.gracePeriodDays > 0, "RegistrarRegistry: grace period must be greater than 0");
        
        FactoryStorage storage fs = LibFactory.load();
        require(fs.proxyImplementation != address(0), "RegistrarRegistration: proxy implementation not set");
        require(fs.entityImplementation != address(0), "RegistrarRegistry: entity implementation not set");
        
        
        //verify signature of terms by owner
        TermsSignatureVerification memory verification = TermsSignatureVerification({
            owner: args.owner,
            termsOwner: address(this),
            terms: args.terms,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature
        });
        LibRegistration.verifyNewEntityTermsSignature(verification);

        //clone the proxy
        proxy = LibClone.clone(fs.proxyImplementation);
        require(proxy != address(0), "RegistrarRegistration: proxy cloning failed");
        IEntityProxy(proxy).setImplementation(fs.entityImplementation);

        //initialize registrar state
        IRegistrar(proxy).init(args.name, args.owner, args.initData);

        //register entity as removable
        _registerRemovableEntity(proxy, address(this), args.terms);

        //transfer tokens if applicable
         if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(proxy).transfer(msg.value);
            }
        }

        emit RegistryAddedEntity(proxy, args.owner);
    }

    /**
     * @dev withdraw funds from the contract
     */
    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "RegistrarRegistry: amount exceeds balance");
        payable(owner()).transfer(amount);
    }

    /**
     * @dev Called by the entity's authority to deactivate the entity for the given reason.
     */
    function deactivateEntity(IRemovableEntity entity, string calldata reason) external onlyAdmin override(BaseRemovableRegistry, IEntityRemoval)  {
        LibEntityRemoval.deactivateEntity(entity, reason);
    }

    /**
     * @dev Called by the entity's terms owner to reactivate the entity.
     */
    function reactivateEntity(IRemovableEntity entity) external onlyAdmin override(BaseRemovableRegistry, IEntityRemoval)   {
        LibEntityRemoval.reactivateEntity(entity);
    }

    /**
     * @dev Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
     * the entity and waiting for the grace period to expire. A grace period must be set to given ample time
     * for the entity to respond to deactivation.
     */
    function removeEntity(IRemovableEntity entity, string calldata reason) external onlyAdmin override(BaseRemovableRegistry, IEntityRemoval)   {
        LibEntityRemoval.removeEntity(entity, reason);
    }

    /**
     * @dev Returns the terms for the given entity address
     
     */
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) public onlyAdmin override(BaseRemovableRegistry, IRemovableRegistry)   {
        LibRegistration.changeEntityTerms(args);
    }
}


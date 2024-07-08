// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableRegistry} from '../../base-types/registry/BaseRemovableRegistry.sol';
import {BaseVectoredRegistry} from '../../base-types/registry/BaseVectoredRegistry.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibRoles} from '../../libraries/LibRoles.sol';
import {LibRegistration, TermsSignatureVerification} from '../../libraries/LibRegistration.sol';
import {FactoryStorage, LibFactory} from '../../libraries/LibFactory.sol';
import {LibClone} from '../../libraries/LibClone.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {LibRegistration, RegistrationWithTermsAndVector} from '../../libraries/LibRegistration.sol';
import {IAssetRegistry, CreateAssetArgs} from './IAssetRegistry.sol';
import {LibAssetRegistry} from './LibAssetRegistry.sol';
import {IAsset, AssetInitArgs} from '../instance/IAsset.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';


contract BaseAssetRegistry is BaseRemovableRegistry, IAssetRegistry {

    /**
     * @dev Determines if the asset from the original chain has been registered
     */
    function assetExists(address original, uint256 chainId) public view returns (bool) {
        return LibAssetRegistry.assetExists(original, chainId);
    }

    /**
     * @dev Registers a new asset with the registry. Only callable by the registry admin
     * after verifying ownership by the issuing company.
     */
    function registerAsset(CreateAssetArgs calldata args) public onlyAdmin returns (address asset)  {
        FactoryStorage storage fs = LibFactory.load();
        require(!assetExists(args.originAddress, args.originChainId), "BaseAssetRegistry: asset already exists");
        require(fs.entityImplementation != address(0), "BaseAssetRegistry: entity implementation not set");
        address entity = LibClone.clone(fs.entityImplementation);
        require(entity != address(0), "BaseAssetRegistry: entity cloning failed");

        AssetInitArgs memory initArgs = AssetInitArgs({
            name: args.name,
            symbol: args.symbol,
            issuer: args.issuer,
            originAddress: args.originAddress,
            originChainId: args.originChainId,
            initData: args.initData
        });

        IAsset(entity).init(initArgs);
       
        RegistrationTerms memory terms = RegistrationTerms({
            fee: 0,
            coveragePeriodDays: 0,
            gracePeriodDays: 30
        });

        _registerRemovableEntity(entity, terms);
        emit RegistryAddedEntity(entity, args.issuer);

        return entity;
    }

    function deactivateAsset(address asset, string calldata reason) public onlyAdmin {
        LibEntityRemoval.deactivateEntity(IRemovableEntity(asset), reason);
        emit RegistryDeactivatedEntity(asset, reason);
    }

    function reactivateAsset(address asset) public onlyAdmin {
        LibEntityRemoval.reactivateEntity(IRemovableEntity(asset));
        emit RegistryReactivatedEntity(asset);
    }

    /**
     * @dev Removes an asset from the registry. Only callable by the registry admin
     */
    function removeAsset(address asset, string calldata reason) public onlyAdmin {
        LibEntityRemoval.removeEntity(IRemovableEntity(asset), reason);
        emit RegistryRemovedEntity(asset, reason);
    }

}
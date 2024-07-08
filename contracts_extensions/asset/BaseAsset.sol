// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatarRegistry} from '../avatar/registry/IAvatarRegistry.sol';
import {ICompanyRegistry} from '../company/registry/ICompanyRegistry.sol';
import {EntityShell} from '../base-types/EntityShell.sol';
import {IExtensionResolver} from '../interfaces/IExtensionResolver.sol';

/**
 * Constructor arguments that immutably reference registries and factories required
 * for asset management.
 */
struct BaseAssetConstructorArgs {
    IExtensionResolver extensionResolver;
    address assetRegistry;
    address avatarRegistry;
    address companyRegistry;
}

/**
 * @title BaseAsset
 * @dev BaseAsset is the base contract for all assets. It provides the basic
 * functionality for asset management, including the ability to add and remove
 * hooks and conditions, as well as the ability to verify that an asset can be
 * viewed or used by a given avatar.
 */
abstract contract BaseAsset is EntityShell {

    /**
     * Fields initialized by asset master-copy constructor
     */
    address public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    ICompanyRegistry public immutable companyRegistry;

    modifier onlyRegistry {
        require(msg.sender == assetRegistry, "BaseAsset: only registry allowed");
        _;
    }


    /**
     * Called once at deploy time. All cloned instances of this asset will retain immutable
     * references to the registries and factories required for asset management.
     */
    constructor(BaseAssetConstructorArgs memory args) EntityShell(args.extensionResolver) {
        require(args.assetRegistry != address(0), "BaseAsset: assetRegistry is the zero address");
        require(args.avatarRegistry != address(0), "BaseAsset: avatarRegistry is the zero address");
        require(args.companyRegistry != address(0), "BaseAsset: companyRegistry is the zero address");
        assetRegistry = args.assetRegistry;
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
    }
}
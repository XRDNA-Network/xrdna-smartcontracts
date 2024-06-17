// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetRegistry} from './IAssetRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IAssetFactory} from './IAssetFactory.sol';
import {IMintableAsset } from './IMintableAsset.sol';

/**
 * @title BaseRegistry
 * @dev BaseRegistry is the base contract for all asset registries. It provides
 * the basic functionality for asset management, including the ability to add and remove
 * assets, as well as the ability to upgrade an asset to a new version.
 */
abstract contract BaseRegistry is IAssetRegistry, AccessControl {

    //role used to manage the registry itself
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    //factor to use for creating new asset instances
    IAssetFactory public assetFactory;

    //mapping of assets by their original address and chain id
    mapping(bytes32 => address) public assetsByOriginalAddressAndChain;

    //mapping of registered assets
    mapping(address => bool) public registeredAssets;

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "AssetRegistry: caller is not an admin");
        _;
    }

    modifier onlyAsset {
        require(registeredAssets[msg.sender], "AssetRegistry: caller is not an asset");
        _;
    }

    /**
      * @dev Constructor to set up the registry with the main admin (role assigner) and 
      * a list of registry admins (that can only manage the registry)
     */
    constructor(address mainAdmin, address[] memory admins, address _assetFactory) {
        require(_assetFactory != address(0), "AssetRegistry: asset factory cannot be zero address");
        require(mainAdmin != address(0), "AssetRegistry: main admin cannot be zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, mainAdmin);
        _grantRole(ADMIN_ROLE, mainAdmin);
        assetFactory = IAssetFactory(_assetFactory);
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "AssetRegistry: admin cannot be zero address");
            _grantRole(ADMIN_ROLE, admins[i]);
        }
    }

    /**
     * @dev chang ethe asset factory used to create new asset instances. Only admins 
     * can call this function.
     */
    function setAssetFactory(address factory) public onlyAdmin {
        require(factory != address(0), "AssetRegistry: asset factory cannot be zero address");
        assetFactory = IAssetFactory(factory);
    }

    /**
     * @dev Get the current version of the asset implementation for the registry. This 
     * relies on the factory's current supported version.
     */
    function currentAssetVersion() external view returns (uint256) {
        return assetFactory.supportsVersion();
    }
    
    /**
     * @dev check whether an asset has been registered for the original asset on the given chain
     */
    function assetExists(address original, uint256 chainId) external view returns (bool) {
        return assetsByOriginalAddressAndChain[keccak256(abi.encodePacked(original, chainId))] != address(0);
    }

    /**
     * @dev Check whether an asset is a registered asset in the interoperability layer
     */
    function isRegisteredAsset(address asset) external view returns (bool) {
        return registeredAssets[asset];
    }

    /**
     * @dev Called by an asset to upgrade itself. This relies on the factory
     * to assign and initialize a new implementation for the asset's proxy address.
     */
    function upgradeAsset(bytes calldata initData) external onlyAsset returns (address) {
        return assetFactory.upgradeAsset(msg.sender, initData);
    }

    /** 
     * @dev Removes an asset from use in the interoperability layer. This is used when
     * a dispute arises over who actually owns the asset on the origin chain, or if 
     * the asset is deemed to be a scam. The discretion of the protocol admin determines
     * asset removal.
     */
    function removeAsset(address asset) public override onlyAdmin {
        require(registeredAssets[asset], "AssetRegistry: asset not registered");
        registeredAssets[asset] = false;
        IMintableAsset ba = IMintableAsset(asset);
        bytes32 hash = keccak256(abi.encode(ba.originAddress(), ba.originChainId()));
        assetsByOriginalAddressAndChain[hash] = address(0);
    }
}
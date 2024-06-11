// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetRegistry} from './IAssetRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IAssetFactory} from './IAssetFactory.sol';

abstract contract BaseRegistry is IAssetRegistry, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IAssetFactory public assetFactory;

    mapping(bytes32 => address) public assetsByOriginalAddressAndChain;
    mapping(address => bool) public registeredAssets;

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "AssetRegistry: caller is not an admin");
        _;
    }

    modifier onlyAsset {
        require(registeredAssets[msg.sender], "AssetRegistry: caller is not an asset");
        _;
    }

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

    function setAssetFactory(address factory) public onlyAdmin {
        require(factory != address(0), "AssetRegistry: asset factory cannot be zero address");
        assetFactory = IAssetFactory(factory);
    }

    function currentAssetVersion() external view returns (uint256) {
        return assetFactory.supportsVersion();
    }
    
    function assetExists(address original, uint256 chainId) external view returns (bool) {
        return assetsByOriginalAddressAndChain[keccak256(abi.encodePacked(original, chainId))] != address(0);
    }

    function isRegisteredAsset(address asset) external view returns (bool) {
        return registeredAssets[asset];
    }

    function upgradeAsset(bytes calldata initData) external onlyAsset {
        assetFactory.upgradeAsset(msg.sender, initData);
    }
}
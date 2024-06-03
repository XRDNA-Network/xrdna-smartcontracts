// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IAssetRegistry.sol";
import "./IAssetFactory.sol";
import "./IAssetCondition.sol";

interface IBasicAsset {
    function issuer() external view returns (address);
    function upgrade(address newAsset) external;
}

contract AssetRegistry is IAssetRegistry, AccessControl {

    struct AssetInfo {
        address issuer;
        IAssetCondition condition;
    }

    IAssetFactory public assetFactory;
    mapping(address => AssetInfo) public registeredAssets;

    event AssetCreated(address indexed asset, uint256 assetType);
    event AssetConditionAdded(address indexed asset, address indexed condition);
    event AssetConditionRemoved(address indexed asset);

    constructor(address[] memory admins, address _assetFactory) {
        require(_assetFactory != address(0), "AssetRegistry: asset factory cannot be zero address");
        assetFactory = IAssetFactory(_assetFactory);
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "AssetRegistry: admin cannot be zero address");
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }

    function setAssetFactory(address _assetFactory) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_assetFactory != address(0), "AssetRegistry: asset factory cannot be zero address");
        assetFactory = IAssetFactory(_assetFactory);
    }

    function isRegisteredAsset(address asset) external view override returns (bool) {
        return registeredAssets[asset].issuer != address(0);
    }

    function registerAsset(uint256 assetType, bytes calldata initData) external onlyRole(DEFAULT_ADMIN_ROLE) returns (address asset) {
        require(address(assetFactory) != address(0), "AssetRegistry: asset factory not set");
        asset = assetFactory.createAsset(assetType, initData);
        registeredAssets[asset] = AssetInfo(IBasicAsset(asset).issuer(), IAssetCondition(address(0)));
        emit AssetCreated(asset, assetType);
    }

    function upgradeAsset(address asset, uint256 assetType, bytes calldata initData) external  {
        require(registeredAssets[asset].issuer != address(0), "AssetRegistry: asset not registered");
        require(registeredAssets[asset].issuer == msg.sender, "AssetRegistry: caller is not the asset issuer");
        AssetInfo storage old = registeredAssets[asset];
        
        address newAsset = assetFactory.createAsset(assetType, initData);
        registeredAssets[newAsset] = AssetInfo(old.issuer,old.condition);
        IBasicAsset(asset).upgrade(newAsset);
        delete registeredAssets[asset];
        emit AssetCreated(newAsset, assetType);
    }

    function getAssetCondition(address asset) external view returns (IAssetCondition) {
        return registeredAssets[asset].condition;
    }

    function canViewAsset(address asset, address world, address company, address experience) external view returns (bool) {
        return address(registeredAssets[asset].condition) == address(0) || registeredAssets[asset].condition.canView(asset, world, company, experience);
    }

    function canUseAsset(address asset, address world, address company, address experience) external view returns (bool) {
        return address(registeredAssets[asset].condition) == address(0) || registeredAssets[asset].condition.canUse(asset, world, company, experience);
    }

    function addAssetCondition(address asset, address condition) external {
        require(registeredAssets[asset].issuer != address(0), "AssetRegistry: asset not registered");
        require(msg.sender == registeredAssets[asset].issuer, "AssetRegistry: caller is not the asset issuer");
        registeredAssets[asset].condition = IAssetCondition(condition);
        emit AssetConditionAdded(asset, condition);
    }

    function removeAssetCondition(address asset) external {
        require(registeredAssets[asset].issuer != address(0), "AssetRegistry: asset not registered");
        require(msg.sender == registeredAssets[asset].issuer, "AssetRegistry: caller is not the asset issuer");
        registeredAssets[asset].condition = IAssetCondition(address(0));
        emit AssetConditionRemoved(asset);
    }
}
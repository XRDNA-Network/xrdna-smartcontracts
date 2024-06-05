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
    function originAddress() external view returns(address);
    function originChainId() external view returns(uint256);
}

contract AssetRegistry is IAssetRegistry, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct AssetInfo {
        address issuer;
        IAssetCondition condition;
    }

    IAssetFactory public assetFactory;
    mapping(address => AssetInfo) public registeredAssets;
    mapping(bytes32 => address) public assetsByOriginalAddressAndChain;

    event AssetCreated(address indexed asset, uint256 assetType);
    event AssetConditionAdded(address indexed asset, address indexed condition);
    event AssetConditionRemoved(address indexed asset);

    constructor(address[] memory admins, address _assetFactory) {
        require(_assetFactory != address(0), "AssetRegistry: asset factory cannot be zero address");
        assetFactory = IAssetFactory(_assetFactory);
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "AssetRegistry: admin cannot be zero address");
            require(_grantRole(ADMIN_ROLE, admins[i]), "AssetRegistry: admin role grant failed");
        }
    }

    function setAssetFactory(address _assetFactory) public onlyRole(ADMIN_ROLE) {
        require(_assetFactory != address(0), "AssetRegistry: asset factory cannot be zero address");
        assetFactory = IAssetFactory(_assetFactory);
    }

    function isRegisteredAsset(address asset) external view override returns (bool) {
        return registeredAssets[asset].issuer != address(0);
    }

    function assetExists(address original, uint256 chainId) public view returns (bool) {
        bytes32 hash = keccak256(abi.encode(original, chainId));
        return assetsByOriginalAddressAndChain[hash] != address(0);
    }

    function registerAsset(uint256 assetType, bytes calldata initData) external onlyRole(ADMIN_ROLE) returns (address asset) {
        require(address(assetFactory) != address(0), "AssetRegistry: asset factory not set");
        asset = assetFactory.createAsset(assetType, initData);
        IBasicAsset ba = IBasicAsset(asset);
        registeredAssets[asset] = AssetInfo(ba.issuer(), IAssetCondition(address(0)));
        bytes32 hash = keccak256(abi.encode(ba.originAddress(), ba.originChainId()));
        assetsByOriginalAddressAndChain[hash] = asset;
        emit AssetCreated(asset, assetType);
    }

    function upgradeAsset(address asset, uint256 assetType, bytes calldata initData) external  {
        require(registeredAssets[asset].issuer != address(0), "AssetRegistry: asset not registered");
        require(registeredAssets[asset].issuer == msg.sender, "AssetRegistry: caller is not the asset issuer");
        AssetInfo storage old = registeredAssets[asset];
        IBasicAsset oa = IBasicAsset(asset);
        bytes32 oHash = keccak256(abi.encode(oa.originAddress(),oa.originChainId()));
        delete assetsByOriginalAddressAndChain[oHash];
        
        //create the new version
        address newAsset = assetFactory.createAsset(assetType, initData);
        require(newAsset != asset, "AssetRegistry: New asset address conflicts with old address");

        registeredAssets[newAsset] = AssetInfo(old.issuer,old.condition);
        IBasicAsset ba = IBasicAsset(newAsset);

        //old asset upgrades to new one and should mark itself as being upgraded
        oa.upgrade(newAsset);

        bytes32 hash = keccak256(abi.encode(ba.originAddress(), ba.originChainId()));
        assetsByOriginalAddressAndChain[hash] = newAsset;
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
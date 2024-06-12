// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IAvatarRegistry} from '../avatar/IAvatarRegistry.sol';
import {IAssetHook} from './IAssetHook.sol';
import {IAvatar} from '../avatar/IAvatar.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IExperience} from '../experience/IExperience.sol';
import {CommonAssetV1Storage} from '../libraries/LibAssetV1Storage.sol';
import {IBasicAsset} from './IBasicAsset.sol';
import {IAssetCondition, AssetCheckArgs} from './IAssetCondition.sol';
import {ICompanyRegistry} from '../company/ICompanyRegistry.sol';

/**
 * Constructor arguments that immutably reference registries and factories required
 * for asset management.
 */
struct BaseAssetArgs {
    address assetFactory;
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
abstract contract BaseAsset is IBasicAsset, ReentrancyGuard {


    event AssetHookAdded(address indexed hook);
    event AssetHookRemoved(address indexed hook);
    event AssetConditionAdded(address indexed condition);
    event AssetConditionRemoved(address indexed condition);

    /**
     * Fields initialized by asset master-copy constructor
     */
    address public immutable assetFactory;
    address public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    ICompanyRegistry public immutable companyRegistry;


    modifier onlyFactory() {
        require(msg.sender == assetFactory, "BaseAsset: only factory allowed");
        _;
    }

    modifier onlyRegistry() {
        require(msg.sender == assetRegistry, "BaseAsset: only registry allowed");
        _;
    }

    /**
     * Called once at deploy time. All cloned instances of this asset will retain immutable
     * references to the registries and factories required for asset management.
     */
    constructor(BaseAssetArgs memory args) {
        require(args.assetFactory != address(0), "BaseAsset: assetFactory is the zero address");
        require(args.assetRegistry != address(0), "BaseAsset: assetRegistry is the zero address");
        require(args.avatarRegistry != address(0), "BaseAsset: avatarRegistry is the zero address");
        require(args.companyRegistry != address(0), "BaseAsset: companyRegistry is the zero address");
        assetFactory = args.assetFactory;
        assetRegistry = args.assetRegistry;
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
    }


    modifier onlyIssuer() {
        require(msg.sender == _loadCommonAttributes().issuer, "BaseAsset: only issuer allowed");
       _;
    }
    

    /**
     * @inheritdoc IBasicAsset
     */
    function issuer() external view override returns (address) {
        return _loadCommonAttributes().issuer;
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function originAddress() external view override returns(address) {
        return _loadCommonAttributes().originAddress;
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function originChainId() external view override returns(uint256) {
        return _loadCommonAttributes().originChainId;
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function hook() external view returns (IAssetHook) {
        return _loadCommonAttributes().hook;
    }

    function addHook(IAssetHook _hook) public override onlyIssuer {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        require(address(_hook) != address(0), "BaseAsset: hook cannot be zero address");
        s.hook = _hook;
        emit AssetHookAdded(address(_hook));
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function removeHook() public override onlyIssuer {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        address h = address(s.hook);
        emit AssetHookRemoved(h);
        delete s.hook;
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function addCondition(IAssetCondition condition) public override onlyIssuer {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        require(address(condition) != address(0), "BaseAsset: condition cannot be zero address");
        s.condition = condition;
        emit AssetConditionAdded(address(condition));
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function removeCondition() public override onlyIssuer {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        address c = address(s.condition);
        emit AssetConditionRemoved(c);
        delete s.condition;
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function canViewAsset(AssetCheckArgs memory args) public view override returns (bool) {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        if (address(s.condition) == address(0)) {
            return true;
        }
        return s.condition.canView(args);
    }

    /**
     * @inheritdoc IBasicAsset
     */
    function canUseAsset(AssetCheckArgs memory args) public view override returns (bool) {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        if (address(s.condition) == address(0)) {
            return true;
        }
        return s.condition.canUse(args);
    }

    
    /**
     * @dev Verifies that the asset issuer matches the company owner of 
     * the avatar's current experience. This is used when an avatar restricts
     * receiving assets to only those issued by the company that owns the
     * the experience they are currently in.
     */
    function _verifyAvatarLocationMatchesIssuer(IAvatar avatar) internal view {
        //get the avatar's current location
        IExperience exp = avatar.location();
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        require(address(exp) != address(0), "BaseAsset: avatar has no location");
        require(exp.company() == s.issuer, "BaseAsset: avatar does not allow assets outside of its current experience");
    }

    function _loadCommonAttributes() internal view virtual returns (CommonAssetV1Storage storage);


}
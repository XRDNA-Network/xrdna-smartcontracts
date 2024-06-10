// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IAvatarRegistry} from '../avatar/IAvatarRegistry.sol';
import {IAssetHook} from './IAssetHook.sol';
import {IAvatar} from '../avatar/IAvatar.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IExperience} from '../experience/IExperience.sol';
import {AssetType} from './IAssetFactory.sol';
import {CommonAssetV1Storage} from '../libraries/LibAssetV1Storage.sol';
import {IBasicAsset} from './IBasicAsset.sol';

interface IExperienceRegistry {
    function getExperienceByVector(VectorAddress memory va) external view returns (IExperience);
}

struct BaseAssetArgs {
    address assetFactory;
    address assetRegistry;
    address avatarRegistry;
    address experienceRegistry;
}

abstract contract BaseAsset is IBasicAsset, ReentrancyGuard {


    event AssetHookAdded(address hook);
    event AssetHookRemoved(address hook);

    /**
     * Fields initialized by asset constructor
     */
    address public immutable assetFactory;
    address public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;


    modifier onlyFactory() {
        require(msg.sender == assetFactory, "BaseAsset: only factory allowed");
        _;
    }

    modifier onlyRegistry() {
        require(msg.sender == assetRegistry, "BaseAsset: only registry allowed");
        _;
    }

    constructor(BaseAssetArgs memory args) {
        require(args.assetFactory != address(0), "BaseAsset: assetFactory is the zero address");
        require(args.assetRegistry != address(0), "BaseAsset: assetRegistry is the zero address");
        require(args.avatarRegistry != address(0), "BaseAsset: avatarRegistry is the zero address");
        require(args.experienceRegistry != address(0), "NonTransferableERC721: experienceRegistry is the zero address");
        assetFactory = args.assetFactory;
        assetRegistry = args.assetRegistry;
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }


    

    modifier onlyIssuer() {
        require(msg.sender == _loadCommonAttributes().issuer, "BaseAsset: only issuer allowed");
       _;
    }

    modifier notUpgraded() {
        bool upgraded = _loadCommonAttributes().upgraded;
        require(!upgraded, "NonTransferableERC20: asset has been upgraded");
        _;
    }
    
    function assetType() external view override returns (uint256) {
        return uint256(_loadCommonAttributes().assetType);
    }

    function issuer() external view override returns (address) {
        return _loadCommonAttributes().issuer;
    }
    function originAddress() external view override returns(address) {
        return _loadCommonAttributes().originAddress;
    }
    function originChainId() external view override returns(uint256) {
        return _loadCommonAttributes().originChainId;
    }

    function addHook(IAssetHook _hook) public override onlyIssuer {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        require(address(s.hook) != address(0), "NonTransferableERC721Asset: hook cannot be zero address");
        s.hook = _hook;
        emit AssetHookAdded(address(_hook));
    }

    function removeHook() public override onlyIssuer {
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        address h = address(s.hook);
        emit AssetHookRemoved(h);
        delete s.hook;
    }

    function _verifyAvatarLocationMatchesIssuer(IAvatar avatar) internal view {
        //get the avatar's current location
        IExperience exp = avatar.location();
        CommonAssetV1Storage storage s = _loadCommonAttributes();
        require(address(exp) != address(0), "BaseAsset: avatar has no location");
        require(exp.company() == s.issuer, "BaseAsset: avatar does not allow assets outside of its current experience");
    }

    function _loadCommonAttributes() internal view virtual returns (CommonAssetV1Storage storage);
}
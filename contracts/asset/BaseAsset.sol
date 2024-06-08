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

interface IExperienceRegistry {
    function getExperienceByVector(VectorAddress memory va) external view returns (IExperience);
}

struct BaseAssetArgs {
    address assetFactory;
    address assetRegistry;
    address avatarRegistry;
    address experienceRegistry;
}

abstract contract BaseAsset is ReentrancyGuard {


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


    /**
     * Fields for each specific asset instance
     */
     //whether the asset has been upgraded to another asset contract version
    bool public upgraded;

    //the type of this asset
    AssetType public assetType;

    //the contract address on the origin chain
    address public originAddress;

    //the address allowed to mint new tokens
    address public issuer;

    //custom mint/transfer behavior
    IAssetHook public hook;

    //original chain id
    uint256 public originChainId;

    modifier onlyIssuer() {
        require(issuer != address(0), "BaseAsset: not initialized");
        _;
    }

    modifier notUpgraded() {
        require(!upgraded, "NonTransferableERC20: asset has been upgraded");
        _;
    }

    function addHook(IAssetHook _hook) public onlyIssuer {
        require(address(hook) != address(0), "NonTransferableERC721Asset: hook cannot be zero address");
        hook = _hook;
        emit AssetHookAdded(address(_hook));
    }

    function removeHook() public onlyIssuer {
        address h = address(hook);
        emit AssetHookRemoved(h);
        delete hook;
    }

    function _verifyAvatarLocationMatchesIssuer(IAvatar avatar) internal view {
        //get the avatar's current location
        IExperience exp = avatar.location();
        require(address(exp) != address(0), "BaseAsset: avatar has no location");
        require(exp.company() == issuer, "BaseAsset: avatar does not allow assets outside of its current experience");
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatarRegistry} from '../../avatar/registry/IAvatarRegistry.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';
import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {AssetStorage, LibAsset} from '../../libraries/LibAsset.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {IAssetCondition, AssetCheckArgs} from '../IAssetCondition.sol';
import {IAsset} from './IAsset.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';
import {IAvatar} from '../../avatar/instance/IAvatar.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';

/**
 * Constructor arguments that immutably reference registries and factories required
 * for asset management.
 */
struct BaseAssetConstructorArgs {
    address assetRegistry;
    address avatarRegistry;
    address companyRegistry;
}

/**
 * Once an asset proxy is cloned, its underlying implementation is initialized. These are the 
 * base asset init args to initialize basic/common asset information
 */
struct BaseInitArgs {
    string name; 
    string symbol;
    address issuer; 
    address originAddress;
    uint256 originChainId;
}

/**
 * @title BaseAsset
 * @dev BaseAsset is the base contract for all assets. It provides the basic
 * functionality for asset management, including the ability to add and remove
 * hooks and conditions, as well as the ability to verify that an asset can be
 * viewed or used by a given avatar.
 */
abstract contract BaseAsset is BaseRemovableEntity, IAsset {

    /**
     * Fields initialized by asset master-copy constructor
     */
    address public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    ICompanyRegistry public immutable companyRegistry;

    modifier onlyIssuer {
        require(LibAsset.load().issuer == msg.sender, "BaseAsset: caller is not the issuer");
        _;
    }

    /**
     * Called once at deploy time. All cloned instances of this asset will retain immutable
     * references to the registries and factories required for asset management.
     */
    constructor(BaseAssetConstructorArgs memory args) {
        require(args.assetRegistry != address(0), "BaseAsset: assetRegistry is the zero address");
        require(args.avatarRegistry != address(0), "BaseAsset: avatarRegistry is the zero address");
        require(args.companyRegistry != address(0), "BaseAsset: companyRegistry is the zero address");
        assetRegistry = args.assetRegistry;
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
    }

    /**
        * @dev Initializes basic asset information
     */
    function initBase(BaseInitArgs memory args) internal {

        //basic asset storage
        AssetStorage storage store = LibAsset.load();
        require(store.issuer == address(0), "NTERC20Asset: already initialized");

        require(args.issuer != address(0), "NTERC20Asset: issuer cannot be zero address");
        require(bytes(args.name).length > 0, "NTERC20Asset: name cannot be empty");
        require(bytes(args.symbol).length > 0, "NTERC20Asset: symbol cannot be empty");
        require(args.originAddress != address(0), "NTERC20Asset: origin address cannot be zero address");   
        require(args.originChainId > 0, "NTERC20Asset: origin chain id must be greater than zero"); 

        store.issuer = args.issuer;
        store.originAddress = args.originAddress;
        store.originChainId = args.originChainId;
        store.symbol = args.symbol;
        
        //registered entity storage info
        LibEntity.load().name = args.name;
       
        //removable entity (asset) storage info
        LibRemovableEntity.load().active = true;
    }

    /**
     * @dev Returns the address of the registry that manages this asset.
     */
    function owningRegistry() internal view override returns (address) {
        return assetRegistry;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory) {
        return LibAsset.load().symbol;
    }

    /**
     * @dev Returns the address of the issuer (company) of the asset.
     */
    function issuer() external view returns (address) {
        return LibAsset.load().issuer;
    }

    /**
     * @dev Returns the address of the origin chain where the asset was created.
     */
    function originAddress() external view returns (address) {
        return LibAsset.load().originAddress;
    }

    /**
     * @dev Returns the chain id of the origin chain where the asset was created.
     */
    function originChainId() external view returns (uint256) {
        return LibAsset.load().originChainId;
    }

    /**
     * @dev sets a condition on the asset for viewing and / or using. Only the issuer can
     * call this function.
     */
    function setCondition(address condition) external onlyIssuer {
        require(condition != address(0), "BaseAsset: condition cannot be zero address");
        LibAsset.load().condition = IAssetCondition(condition);
        emit AssetConditionSet(condition);
    }

    /**
     * @dev removes the condition on the asset for viewing and / or using. Only the issuer can
        * call this function.
     */
    function removeCondition() external onlyIssuer {
        delete LibAsset.load().condition;
        emit AssetConditionRemoved();
    }   

    /**
     * @dev Checks if the asset can be viewed based on the world/company/experience/avatar
     */
    function canViewAsset(AssetCheckArgs memory args) external view returns (bool) {
        IAssetCondition con = LibAsset.load().condition;
        return address(con) == address(0) || con.canView(args);
    }

    /**
     * @dev Checks if the asset can be used based on the world/company/experience/avatar
     */
    function canUseAsset(AssetCheckArgs memory args) external view returns (bool) {
        IAssetCondition con = LibAsset.load().condition;
        return address(con) == address(0) || con.canUse(args);
    }


    /**
     * @dev Verifies that the issuer of this asset also ows the experience for the avatar. 
     * This prevents airdropping tokens when not wanted by the avatar.
     */
    function _verifyAvatarLocationMatchesIssuer(IAvatar avatar) internal view {
        //get the avatar's current location
        address e = avatar.location();
        require(e != address(0), "BaseAsset: avatar has no location");
        IExperience exp = IExperience(e);
        require(exp.company() == LibAsset.load().issuer, "BaseAsset: avatar does not allow assets outside of its current experience");
    }
}
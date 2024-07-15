// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {IVectoredEntity} from '../../base-types/entity/IVectoredEntity.sol';

/**
 * @dev Arguments for companies to add an experience to a world.
 */
struct AddExperienceArgs {
    //unique name of the experience
    string name;

    //initialization data
    bytes initData;
}

/**
 * @dev Arguments for delegating an avatar jump to a company.
 */
struct DelegatedAvatarJumpRequest {
    //avatar making jump
    address avatar;

    //the portal id of the jump (relative to the destination)
    uint256 portalId;

    //the fee required to make the jump
    uint256 agreedFee;

    //signature of the avatar owner agreeing to the jump and fees
    bytes avatarOwnerSignature;
}

struct CompanyInitArgs {
    //name of the company
    string name;

    //owner of the company
    address owner;

    //world in which the company operates
    address world;

    //vector address assigned to the company
    VectorAddress vector;

    //initialization data
    bytes initData;

}

/**
 * @title ICompany
 * @dev Interface for a company that can add experiences to a world and mint assets.
 * Companies register through Worlds in order to offer experiences to avatars and 
 * create assets within worlds.
 */
interface ICompany is IAccessControl, IVectoredEntity, IRemovableEntity {

    event CompanyAddedExperience(address indexed experience, uint256 indexed portalId);
    event CompanyDeactivatedExperience(address indexed experience, string reason);
    event CompanyReactivatedExperience(address indexed experience);
    event CompanyRemovedExperience(address indexed experience, string reason, uint256 indexed portalId);
    event CompanyAddedExperienceCondition(address indexed experience, address indexed condition);
    event CompanyRemovedExperienceCondition(address indexed experience);
    event CompanyChangedExperiencePortalFee(address indexed experience, uint256 indexed fee);
    event CompanyAddedAssetCondition(address indexed asset, address indexed condition);
    event CompanyRemovedAssetCondition(address indexed asset);
    event CompanyAddedAssetHook(address indexed asset, address indexed hook);
    event CompanyRemovedAssetHook(address indexed asset);
    event CompanyAddedExperienceHook(address indexed experience, address indexed hook);
    event CompanyRemovedExperienceHook(address indexed experience);
    event CompanyJumpedForAvatar(address indexed avatar, uint256 indexed portalId, uint256 indexed fee);
    event CompanyUpgradedExperience(address indexed experience, address indexed nextVersion);
    event CompanyUpgradedAsset(address indexed asset, address indexed nextVersion);

    event CompanyUpgraded(address indexed oldVersion, address indexed nextVersion);
    event CompanyHookSet(address indexed hook);
    event CompanyHookRemoved();
    event AssetMinted(address indexed asset, address indexed to, uint256 indexed amountOrTokenId);
    event AssetRevoked(address indexed asset, address indexed holder, uint256 indexed amountOrTokenId);
    event CompanyDeactivated();
    event CompanyReactivated();


    function init(CompanyInitArgs memory args) external;

    /**
        * @dev Returns the address of the world in which the company operates.
     */
    function world() external view returns (address);

    /**
     * @dev Returns whether this company can mint the given asset to the given address.
     * The data parameter is dependent on the type of asset.
     */
    function canMintERC20(address asset, address to, uint256 amount) external view returns (bool);
    
    /**
     * @dev Returns whether this company can mint the given ERC721 to the given address.
     */
    function canMintERC721(address asset, address to) external view returns (bool);

    /**
     * @dev Sets a new BaseURI for an ERC721 asset. This should only be called by admins
     */
    function setERC721BaseURI(address asset, string calldata baseURI) external;

    /**
     * @dev Adds an experience to the world. This also creates a portal into the 
     * experience and registers it in the PortalRegistry. It is assumed that the 
     * initialization data for the experience will include the expected fee
     * for the portal.
     */
    function addExperience(AddExperienceArgs memory args) external returns (address, uint256);

    /**
     * @dev Deactivates an experience. This will prevent avatars from entering the experience
     * but will not remove the experience from the world. This can only be called by the
     * company admin.
     */
    function deactivateExperience(address experience, string calldata reason) external;

    /**
     * @dev Reactivates an experience that was previously deactivated. This can only be called
     * by the company admin.
     */
    function reactivateExperience(address experience) external;

    /**
     * @dev Removes an experience from the world. This also removes the portal into the 
     * experience and unregisters it from the PortalRegistry. This can only be called
     * by company admin
     */
    function removeExperience(address experience, string calldata reason) external;

    /**
     * @dev Request that the given company-owned experience upgrade itself
     */
    function upgradeExperience(address exp) external;

    /**
     * @dev Mints the given asset to the given address with the given amount.
     */
    function mintERC20(address asset, address to, uint256 amount) external;

    /**
     * @dev Mints an ERC721 to the given address. The token ID associated with the 
     * minted asset is an incremental counter for the asset. This is intentionally
     * decoupled from its originating asset on another chain to preserve privacy.
     */
    function mintERC721(address asset, address to) external;

    /**
     * @dev Revokes the given amount of the given asset from the given address. The data
     * parameter is dependent on the type of asset. This is likely called when an avatar
     * owner transfers the original asset on another chain (i.e. all assets in the 
     * interoperability layer are synthetic assets that represent assets on other chains).
     */
    function revokeERC20(address asset, address holder, uint256 amount) external;

    /**
     * @dev Revokes the given ERC721 token from the given address. This is likely called
     * when an avatar owner transfers the original asset on another chain (i.e. all assets
     * in the interoperability layer are synthetic assets that represent assets on other chains).
     */
    function revokeERC721(address asset, address holder, uint256 tokenId) external;

    /**
     * @dev Upgrades the given ERC20 asset to a new version. This is useful for companies
     * that want to upgrade the logic of their assets. This can only be called by the company
     * admin.
     */
    function upgradeERC20(address asset) external;

    /**
     * @dev Upgrades the given ERC721 asset to a new version. This is useful for companies
     * that want to upgrade the logic of their assets. This can only be called by the company
     * admin.
     */
    function upgradeERC721(address asset) external;

    /**
     * @dev Withdraws the given amount of funds from the company. Only the owner can withdraw funds.
     */
    function withdraw(uint256 amount) external;

    /**
     * @dev Adds an experience condition to an experience. Going through the company
     * contract provides the necessary authorization checks and that only the experience
     * owner can add conditions.
     */
    function addExperienceCondition(address experience, address condition) external;

    /**
     * @dev Removes an experience condition from an experience
     */
    function removeExperienceCondition(address experience) external;

    /**
     * @dev Changes the fee associated with a portal to an experience owned by the company.
     * Going through the company provides appropriate authorization checks.
     */
    function changeExperiencePortalFee(address experience, uint256 fee) external;

    /**
     * @dev Adds an asset condition to an asset. Going through the company
     * contract provides the necessary authorization checks and that only the asset
     * issuer can add conditions.
     */
    function addAssetCondition(address asset, address condition) external;

    /**
     * @dev Removes an asset condition from an asset
     */
    function removeAssetCondition(address asset) external;

    /**
     * @dev Delegates a jump for an avatar to the company. This allows the company to
     * pay the transaction fee but charge the avatar owner for the jump. This is useful
     * for companies that want to offer free jumps to avatars but charge them for the
     * experience.
     */
    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) external;
    
}

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct AssetCheckArgs {
    address asset;
    address world;
    address company;
    address experience;
    address avatar;
}

/**
 * @title IAssetCondition
 * @dev This interface should be implemented to customize the conditional behavior of 
 * viewing or using an asset in the interoperability layer. Companies can deploy custom
 * conditions and add them to their controlled assets.
 * 
 * There are some situations where assets may or may not be viewable or usable in 
 * a metaverse environment. Licensing, restrictions, or other conditions may have to be 
 * met before the asset is allowed. This condition can be added to any asset by its issuing
 * company to enforce rules. Note, however, that the only time these rules are enforced
 * on-chain is when an Avatar attempt to add a wearable to itself. All other checks are
 * likely to happen off-chain or within other metaverse smart contracts interacting with
 * avatars and their assets.
 */
interface IAssetCondition {

    /**
     * @dev Returns true if the asset can be viewed by the given world, company, experience, and avatar.
     */
    function canView(AssetCheckArgs memory args) external view returns (bool);

    /**
     * @dev Returns true if the asset can be used by the given world, company, experience, and avatar.
     */
    function canUse(AssetCheckArgs memory args) external view returns (bool);
}
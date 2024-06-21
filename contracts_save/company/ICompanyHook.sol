// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AddExperienceArgs} from './ICompany.sol';

/**
 * @title ICompanyHook
  * @dev Interface for a hook that can be called by a company to validate certain company
    * operations. Any hook function that returns false will prevent the action from occurring.
 */
interface ICompanyHook {

    ///////////////////////////////////////////////////////////////////////////
    // Experience related hooks
    ///////////////////////////////////////////////////////////////////////////
    /**
     * @dev Called before adding an experience to a world.
     */
    function beforeAddExperience(AddExperienceArgs memory args) external returns (bool);

    /**
     * @dev Called before removing an experience from a company/world.
     */
    function beforeRemoveExperience(address experience) external returns (bool);

    /**
     * @dev Called before adding a hook to an experience.
     */
    function beforeAddExperienceHook(address experience, address hook) external returns (bool);

    /**
     * @dev Called before removing a hook from an experience.
     */
    function beforeRemoveExperienceHook(address experience) external returns (bool);

    /**
     * @dev Called before upgrading an experience.
     */
    function beforeUpgradeExperience(address experience, bytes calldata data) external returns (bool);
    
    /**
     * @dev Called before adding a condition to an experience's portal
     */
    function beforeAddPortalCondition(address experience, address condition) external returns (bool);

    /**
     * @dev Called before removing a condition from an experience's portal.
     */
    function beforeRemovePortalCondition(address experience) external returns (bool);

    /**
     * @dev Called before changing the portal fees.
     */
    function beforeChangePortalFees(uint256 newFee) external returns (bool);

    ///////////////////////////////////////////////////////////////////////////
    // Asset related hooks
    ///////////////////////////////////////////////////////////////////////////
    /**
     * @dev Called before minting an asset.
     */
    function beforeMint(address asset, address to, bytes calldata data) external returns (bool);
    
    /**
     * @dev Called before revoking an asset.
     */
    function beforeRevoke(address asset, address holder, bytes calldata data) external returns (bool);

    /**
     * @dev Called before adding an asset condition.
     */
    function beforeAddAssetCondition(address asset, address condition) external returns (bool);

    /**
     * @dev Called before removing an asset condition.
     */
    function beforeRemoveAssetCondition(address asset) external returns (bool);

    /**
     * @dev Called before adding an asset hook.
     */
    function beforeAddAssetHook(address asset, address hook) external returns (bool);

    /**
     * @dev Called before removing an asset hook.
     */
    function beforeRemoveAssetHook(address asset) external returns (bool);

    /**
     * @dev Called before upgrading an asset.
     */
    function beforeUpgradeAsset(address asset, bytes calldata data) external returns (bool);


    ///////////////////////////////////////////////////////////////////////////
    // Avatar related hooks
    ///////////////////////////////////////////////////////////////////////////
    /**
     * @dev Called before paying for an avatar to jump to destination
     */
    function beforeDelegatedJump(address avatar, uint256 portalId, uint256 fee) external returns (bool);

    ///////////////////////////////////////////////////////////////////////////
    // Company related hooks
    ///////////////////////////////////////////////////////////////////////////
    /**
     * @dev Called before upgrading company contract.
     */
    function beforeUpgrade(bytes calldata data) external returns (bool);
}
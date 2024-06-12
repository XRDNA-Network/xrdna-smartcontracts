// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IAvatarFactory {

    /**
     * @dev Upgrades an existing avatar to the latest version. Called by the registry
     * to carry out the upgrade.
     */
    function upgradeAvatar(address avatar, bytes calldata initData) external;

    /**
     * @dev Creates a new avatar contract and initializes it with the given data. Called by the registry
     */
    function createAvatar(address company, address defaultExperience, string memory username, bytes memory initData) external returns (address);
}
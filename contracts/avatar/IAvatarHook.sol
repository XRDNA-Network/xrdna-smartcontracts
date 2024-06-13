// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * Jump request details sent to a hook for pre-jump verification.
 */
struct HookAvatarJumpRequest {
    address avatar;
    address destination;
}

/**
 * @title IAvatarHook
 * @dev Interface for an avatar hook that can be added by the avatar owner to customize
 * behavior before jumping and when receiving assets. This can be useful for a tech-savvy
 * avatar owner to record assets received and prevent unwanted jumps.
 */
interface IAvatarHook {
    function beforeJump(HookAvatarJumpRequest memory request) external returns (bool);
    function onReceiveERC721(address avatar, address asset, uint256 tokenId) external returns(bool);
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct HookAvatarJumpRequest {
    address avatar;
    address destination;
}

interface IAvatarHook {
    function beforeJump(HookAvatarJumpRequest memory request) external returns (bool);
    function onReceiveERC721(address avatar, address asset, uint256 tokenId) external returns(bool);
}
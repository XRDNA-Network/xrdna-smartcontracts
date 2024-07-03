
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct NewAvatarArgs {

    //whether any attached tokens for registration are sent to the avatar owner address or
    //to the avatar contract itself
    bool sendTokensToOwner;

    //owner of the avatar contract
    address owner;

    //avatar's globally unique name
    string name;

    //avatar contract init data, if any
    bytes initData;
}

interface IWorldAddAvatar {

    /**
     * @dev Registers a new avatar contract. Must be called by a world signer
     */
    function registerAvatar(NewAvatarArgs memory args) external payable returns (address avatar);
}
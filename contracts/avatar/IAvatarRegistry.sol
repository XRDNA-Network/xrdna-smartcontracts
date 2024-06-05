// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct AvatarRegistrationRequest {
    //whether to send tokens to the avatar owner account or contract address
    bool sendTokensToAvatarOwner;

    //the addres sof the avatar owner
    address avatarOwner;

    //the address of the default experience contract where the new avatar will start
    address defaultExperience;

    //the username of the new avatar, must be globally unique, case-insensitive
    string username;

    //initialization data to pass to the avatar contract
    bytes initData;
}

interface IAvatarRegistry {

    /**
     * @dev Check if an address is an avatar
     * @param a The address to check
     * @return True if the address is a registered avatar, false otherwise
     */
    function isAvatar(address a) external view returns (bool);

    /**
     * @dev Get the avatar contract address for a given username
     * @param username The username to search for (case-insensitive)
     * @return The address of the avatar contract, or address(0) if not found
     */
    function findByUsername(string memory username) external view returns (address);

    /**
     * @dev Register a new avatar. This must be called by a registered World contract. Funds
     * can be attached to the txn and will be distributed to avatar contract or owner depending
     * on the registration request.
     * @param registration The registration request
     */
    function registerAvatar(AvatarRegistrationRequest memory registration) external payable;
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatarRegistry, AvatarRegistrationRequest} from './IAvatarRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IAvatarFactory} from '../avatar/IAvatarFactory.sol';

interface IWorldRegistry {
    function isWorld(address world) external view returns (bool);
}

struct AvatarRegistryArgs {
    address mainAdmin;
    address[] admins;
    address avatarFactory;
    address worldRegistry;
}

contract AvatarRegistry is IAvatarRegistry, AccessControl {
    using LibStringCase for string;

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

    IAvatarFactory public avatarFactory;
    IWorldRegistry public worldRegistry;
    mapping(string => address) private _avatarsByName;
    mapping(address => bool) private _avatarsByAddress;

    constructor(AvatarRegistryArgs memory args) {
        require(args.mainAdmin != address(0), 'AvatarRegistry: main admin address cannot be 0');
        require(_grantRole(DEFAULT_ADMIN_ROLE, args.mainAdmin), 'AvatarRegistry: default admin role grant failed');
        require(_grantRole(ADMIN_ROLE, args.mainAdmin), 'AvatarRegistry: admin role grant failed');
        require(args.avatarFactory != address(0), 'AvatarRegistry: factory address cannot be 0');
        require(args.worldRegistry != address(0), 'AvatarRegistry: world registry address cannot be 0');
        avatarFactory = IAvatarFactory(args.avatarFactory);
        worldRegistry = IWorldRegistry(args.worldRegistry);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), 'AvatarRegistry: admin address cannot be 0');
            require(_grantRole(ADMIN_ROLE, args.admins[i]), 'AvatarRegistry: admin role grant failed');
        }
    }

    receive() external payable {}

     /**
     * @dev Check if an address is an avatar
     * @param a The address to check
     * @return True if the address is a registered avatar, false otherwise
     */
    function isAvatar(address a) external view returns (bool) {
        return _avatarsByAddress[a];
    }

    /**
     * @dev Get the avatar contract address for a given username
     * @param username The username to search for (case-insensitive)
     * @return The address of the avatar contract, or address(0) if not found
     */
    function findByUsername(string memory username) external view returns (address) {
        string memory low = username.lower();
        return _avatarsByName[low];
    }

    function nameAvailable(string memory username) external view returns (bool) {
        string memory low = username.lower();
        return _avatarsByName[low] == address(0);
    }

    /**
     * @dev Register a new avatar. This must be called by a registered World contract. Funds
     * can be attached to the txn and will be distributed to avatar contract or owner depending
     * on the registration request.
     * @param registration The registration request
     */
    function registerAvatar(AvatarRegistrationRequest memory registration) external payable {
        //call must come from world contract to verify that a world signer authorizes the 
        //creation of the avatar.
        require(worldRegistry.isWorld(msg.sender), 'AvatarRegistry: caller is not a world');
        address proxy = avatarFactory.createAvatar(registration.avatarOwner, registration.defaultExperience, registration.initData);
        if(msg.value > 0) {
            if (registration.sendTokensToAvatarOwner) {
                payable(registration.avatarOwner).transfer(msg.value);
            } else {
                payable(proxy).transfer(msg.value);
            }
        }
        emit AvatarCreated(proxy, registration.avatarOwner, registration.defaultExperience);
    }
}
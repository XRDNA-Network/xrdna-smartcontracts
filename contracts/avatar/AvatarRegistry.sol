// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatarRegistry, AvatarRegistrationRequest} from './IAvatarRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IAvatarFactory} from '../avatar/IAvatarFactory.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IAvatar} from './IAvatar.sol';
import {IExperience} from '../experience/IExperience.sol';

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
    string public override currentAvatarVersion = '0.1';

    modifier onlyAvatar {
        require(_avatarsByAddress[msg.sender], 'AvatarRegistry: caller is not an avatar');
        _;
    }

    constructor(AvatarRegistryArgs memory args) {
        require(args.mainAdmin != address(0), 'AvatarRegistry: main admin address cannot be 0');
        _grantRole(DEFAULT_ADMIN_ROLE, args.mainAdmin);
        _grantRole(ADMIN_ROLE, args.mainAdmin);
        require(args.avatarFactory != address(0), 'AvatarRegistry: factory address cannot be 0');
        require(args.worldRegistry != address(0), 'AvatarRegistry: world registry address cannot be 0');
        avatarFactory = IAvatarFactory(args.avatarFactory);
        worldRegistry = IWorldRegistry(args.worldRegistry);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), 'AvatarRegistry: admin address cannot be 0');
            _grantRole(ADMIN_ROLE, args.admins[i]);
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

    function setAvatarFactory(address factory) external onlyRole(ADMIN_ROLE) {
        address old = address(avatarFactory);
        require(factory != address(0), 'AvatarRegistry: factory address cannot be 0');
        avatarFactory = IAvatarFactory(factory);
        emit AvatarFactoryChanged(old, factory);
    }

    /**
     * @dev Register a new avatar. This must be called by a registered World contract. Funds
     * can be attached to the txn and will be distributed to avatar contract or owner depending
     * on the registration request.
     * @param registration The registration request
     */
    function registerAvatar(AvatarRegistrationRequest memory registration) external payable returns (address proxy) {
        //call must come from world contract to verify that a world signer authorizes the 
        //creation of the avatar.
        require(worldRegistry.isWorld(msg.sender), 'AvatarRegistry: caller is not a world');
        string memory lowerName = registration.username.lower();
        require(_avatarsByName[lowerName] == address(0), 'AvatarRegistry: username already exists');
        proxy = avatarFactory.createAvatar(registration.avatarOwner, registration.defaultExperience, registration.username, registration.initData);
        if(msg.value > 0) {
            if (registration.sendTokensToAvatarOwner) {
                payable(registration.avatarOwner).transfer(msg.value);
            } else {
                payable(proxy).transfer(msg.value);
            }
        }
        _avatarsByName[lowerName] = proxy;
        _avatarsByAddress[proxy] = true;
        emit AvatarCreated(proxy, registration.avatarOwner, registration.defaultExperience);
    }

    function upgradeAvatar(bytes calldata initData) public onlyAvatar {
        IAvatar avatar = IAvatar(msg.sender);
        IExperience loc = avatar.location();
        address owner = avatar.owner();
        string memory name = avatar.username().lower();
        address proxy = avatarFactory.createAvatar(owner, address(loc), name, initData);
        avatar.upgradeComplete(proxy);
        delete _avatarsByAddress[msg.sender];
        _avatarsByName[name] = proxy;
        _avatarsByAddress[proxy] = true;
    }

    function setCurrentAvatarVersion(string memory v) public onlyRole(ADMIN_ROLE) {
        currentAvatarVersion = v;
    }
}
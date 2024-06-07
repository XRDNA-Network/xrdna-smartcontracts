// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AvatarRegistrationRequest} from '../../avatar/IAvatarRegistry.sol';
import {WorldCreateRequest} from './IWorldFactory0_2.sol';
import {VectorAddress} from '../../VectorAddress.sol';
import {IWorldHook} from './IWorldHook.sol';

struct CompanyRegistrationArgs {
    address owner;
    string name;
    bytes initData;
}

interface IWorld0_2 {

    event ReceivedFunds(address indexed sender, uint256 value);
    event SignerAdded(address indexed signer);
    event SignerRemoved(address indexed signer);
    event CompanyRegistered(address indexed company, VectorAddress vector, string name);
    event AvatarRegistered(address indexed avatar, address indexed experience);
    event WorldUpgraded(address indexed oldWorld, address indexed newWorld);
    event WorldHookSet(address indexed hook);
    event WorldHookRemoved();

    function getOwner() external view returns (address);
    function getBaseVector() external view returns (VectorAddress memory);
    function getName() external view returns (string memory);
    function addSigners(address[] memory sigs) external;
    function removeSigners(address[] memory sigs) external;
    function version() external view returns (string memory);
    
    function registerCompany(CompanyRegistrationArgs memory args) external returns (address company);
    function registerAvatar(AvatarRegistrationRequest memory args) external returns (address avatar);
    function upgrade(bytes calldata initData) external;
    function upgraded() external view returns (bool);
    function init(WorldCreateRequest memory request) external;
    function upgradeComplete(address nextVersion) external;
    function setHook(IWorldHook hook) external;
    function removeHook() external;
}
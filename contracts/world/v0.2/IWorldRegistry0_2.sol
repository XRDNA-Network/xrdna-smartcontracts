// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../VectorAddress.sol';

struct WorldRegistrationRequest {
    bool sendTokensToWorldOwner;
    address oldWorld;
    address owner;
    VectorAddress baseVector;
    string name;
    uint256 registrarId;
    bytes initData;
    bytes vectorAuthoritySignature;
}

interface IWorldRegistry0_2 {

    event WorldRegistered(address indexed world, address indexed owner, VectorAddress vectorAddress);
    event VectorAddressAuthorityAdded(address indexed authority);
    event VectorAddressAuthorityRemoved(address indexed authority);

    
    function getWorldByName(string memory name) external view returns (address);
    function isWorld(address world) external view returns (bool);
    function isVectorAddressAuthority(address auth) external view returns(bool);

    function setWorldFactory(address factory) external;
    function addVectorAddressAuthority(address auth) external;
    function removeVectorAddressAuthority(address auth) external;
    function register(WorldRegistrationRequest memory request) external payable;
    function registrarUpgradeWorld(uint256 registrarId, address oldWorld, bytes calldata initData) external;
    function worldUpgradeSelf(bytes calldata initData) external;
}
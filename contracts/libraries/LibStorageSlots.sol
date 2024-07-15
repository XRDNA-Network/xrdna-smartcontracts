// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

//organize storage slot addresses in one place to make sure they're unique
library LibStorageSlots {

    //see EIP-7201 for details on slot address algorithm
    
    bytes32 constant ENTITY_PROXY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.entity.proxy.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    
    bytes32 constant ENTITY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.entity.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ACCESS_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.access.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant FACTORY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.entity.factory.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant REGISTRATION_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.registration.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ACTIVATION_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.activation.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant WORLD_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.world.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant COMPANY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.company.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant AVATAR_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.avatar.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant EXPERIENCE_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.experience.storage.v1'))) - 1)) & bytes32(uint256(0xff));

    bytes32 constant ASSET_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.asset.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ASSET_REGISTRY = keccak256(abi.encode(uint256(keccak256(bytes('xr.asset.registry.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ERC20_ASSET_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.erc20.asset.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ERC721_ASSET_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.erc721.asset.storage.v1'))) - 1)) & bytes32(uint256(0xff));

    bytes32 constant PORTAL_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.portal.storage.v1'))) - 1)) & bytes32(uint256(0xff));
}
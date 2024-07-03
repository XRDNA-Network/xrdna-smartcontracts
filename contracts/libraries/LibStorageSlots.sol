// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

library LibStorageSlots {

    //see EIP-7201 for details on slot address algorithm
    bytes32 constant EXTENSIONS_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.extensions.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant EXTENSION_REGISTRY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.core.extension.registry.storage.v1'))) - 1)) & bytes32(uint256(0xff));

    bytes32 constant CORE_PROXY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.core.proxy.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ENTITY_PROXY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.entity.proxy.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    
    bytes32 constant ENTITY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.entity.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ACCESS_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.access.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant FACTORY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.entity.factory.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant REGISTRATION_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.registration.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant REGISTRATION_TERMS_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.registration.terms.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant ACTIVATION_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.activation.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant TERMS_OWNER_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.terms.owner.storage.v1'))) - 1)) & bytes32(uint256(0xff));

    bytes32 constant REGISTRY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.registry.storage.v1'))) - 1)) & bytes32(uint256(0xff));

    bytes32 constant WORLD_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.world.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant COMPANY_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.company.storage.v1'))) - 1)) & bytes32(uint256(0xff));
    bytes32 constant AVATAR_STORAGE = keccak256(abi.encode(uint256(keccak256(bytes('xr.avatar.storage.v1'))) - 1)) & bytes32(uint256(0xff));
}
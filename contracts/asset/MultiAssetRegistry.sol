// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IMultiAssetRegistry} from './IMultiAssetRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IAssetRegistry} from './IAssetRegistry.sol';

struct MultiAssetRegistryConstructorArgs {
    address mainAdmin;
    address[] admins;
    IAssetRegistry[] registries;
}

contract MultiAssetRegistry is IMultiAssetRegistry, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
    IAssetRegistry[] public registries;

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), 'MultiAssetRegistry: caller is not an admin');
        _;
    }

    constructor(MultiAssetRegistryConstructorArgs memory args) {
        require(args.mainAdmin != address(0), 'MultiAssetRegistry: mainAdmin is the zero address');
        require(args.admins.length > 0, 'MultiAssetRegistry: no admins');
        require(args.registries.length > 0, 'MultiAssetRegistry: no registries');
        _grantRole(DEFAULT_ADMIN_ROLE, args.mainAdmin);
        _grantRole(ADMIN_ROLE, args.mainAdmin);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), 'MultiAssetRegistry: admin is the zero address');
            _grantRole(ADMIN_ROLE, args.admins[i]);
        }
        for (uint256 i = 0; i < args.registries.length; i++) {
            require(args.registries[i] != IAssetRegistry(address(0)), 'MultiAssetRegistry: registry is the zero address');
            registries.push(args.registries[i]);
        }
    }

    function isRegisteredAsset(address asset) external view override returns (bool) {
        for (uint256 i = 0; i < registries.length; i++) {
            if (registries[i].isRegisteredAsset(asset)) {
                return true;
            }
        }
        return false;
    }

    function registerRegistry(IAssetRegistry registry) external onlyAdmin override {
        require(registry != IAssetRegistry(address(0)), 'MultiAssetRegistry: registry is the zero address');
        registries.push(registry);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IMultiAssetRegistry} from './IMultiAssetRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IAssetRegistry} from './registry/IAssetRegistry.sol';

struct MultiAssetRegistryConstructorArgs {
    //role assigner and registry admin
    address mainAdmin;

    //register admins
    address[] admins;

    //initial set of registries to check
    IAssetRegistry[] registries;
}

/*
 * @inheritdoc IMultiAssetRegistry
 */
contract MultiAssetRegistry is IMultiAssetRegistry, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
    IAssetRegistry[] public registries;

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), 'MultiAssetRegistry: caller is not an admin');
        _;
    }

    constructor(MultiAssetRegistryConstructorArgs memory args) {
        require(args.mainAdmin != address(0), 'MultiAssetRegistry: mainAdmin is the zero address');
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

    /**
     * @inheritdoc IMultiAssetRegistry
     */
    function isRegistered(address asset) external view override returns (bool) {
        uint256 len = registries.length;
        for (uint256 i = 0; i < len; i++) {
            if (registries[i].isRegistered(asset)) {
                return true;
            }
        }
        return false;
    }

    /**
     * @inheritdoc IMultiAssetRegistry
     */
    function registerRegistry(IAssetRegistry registry) external onlyAdmin override {
        require(registry != IAssetRegistry(address(0)), 'MultiAssetRegistry: registry is the zero address');
        registries.push(registry);
    }
}
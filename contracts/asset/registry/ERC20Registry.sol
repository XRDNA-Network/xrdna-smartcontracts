// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseAssetRegistry} from './BaseAssetRegistry.sol';
import {Version} from '../../libraries/LibVersion.sol';

/**
 * @title ERC20Registry
 * @dev ERC20Registry is the registry for all ERC20 asset types. It provides the basic
 * functionality for ERC20 asset management, including the ability to register and remove ERC20 assets.
 */
contract ERC20Registry is BaseAssetRegistry {

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }
}
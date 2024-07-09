// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseAssetRegistry} from './BaseAssetRegistry.sol';
import {Version} from '../../libraries/LibTypes.sol';

contract ERC20Registry is BaseAssetRegistry {

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }
}
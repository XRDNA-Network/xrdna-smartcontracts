// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistry} from '../../base-types/registry/BaseRegistry.sol';
import {BaseAssetRegistry} from './BaseAssetRegistry.sol';
import {Version} from '../../libraries/LibTypes.sol';


/**
 * @title ERC721Registry
 * @dev ERC721Registry is the registry contract for ERC721 assets. It provides the basic
 * functionality for ERC721 asset management, including the ability to register and remove assets.
 */
contract ERC721Registry is BaseAssetRegistry {

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }
}
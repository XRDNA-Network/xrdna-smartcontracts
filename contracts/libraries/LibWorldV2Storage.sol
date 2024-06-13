// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorldHook} from '../world/v0.2/IWorldHook.sol';
import {VectorAddress} from '../VectorAddress.sol';

/**
 * @dev Storage data for WorldV2
 
 */
struct WorldV2Storage {
    //world primary owner
    address owner;

    //v1 of world is applicable
    address oldVersion;

    //custom hook installed by owner
    IWorldHook hook;

    //world's spatial vector address assigned by registrar
    VectorAddress baseVector;

    //world's globally unique name
    string name;

    //counter for company vector address plane field
    uint256 nextP;
}

/**
    * @dev Library for loading WorldV2Storage
 */
library LibWorldV2Storage {

    bytes32 public constant WorldStorageSlot = keccak256("_WorldV2Storage");

    /**
     * @dev Load WorldV2Storage from storage
     */
    function load() internal pure returns (WorldV2Storage storage ws) {
        bytes32 slot = WorldStorageSlot;
        assembly {
            ws.slot := slot
        }
    }

}
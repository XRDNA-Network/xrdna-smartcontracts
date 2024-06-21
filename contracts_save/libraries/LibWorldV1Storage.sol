// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorldHook} from '../world/IWorldHook.sol';
import {VectorAddress} from '../VectorAddress.sol';

/**
 * @dev Storage data for WorldV1
 
 */
struct WorldV1Storage {
    //whether the world has an active registration and can be used
    bool active;

    //world primary owner
    address owner;

    //registrar for the world
    address registrar;

    //world's spatial vector address assigned by registrar
    VectorAddress baseVector;

    //world's globally unique name
    string name;

    //counter for company vector address plane field
    uint256 nextP;
}

/**
    * @dev Library for loading WorldV1Storage
 */
library LibWorldV1Storage {

    bytes32 public constant WorldStorageSlot = keccak256("_WorldV1Storage");

    /**
     * @dev Load WorldV1Storage from storage
     */
    function load() internal pure returns (WorldV1Storage storage ws) {
        bytes32 slot = WorldStorageSlot;
        assembly {
            ws.slot := slot
        }
    }

}
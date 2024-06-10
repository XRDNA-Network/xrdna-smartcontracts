// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorldHook} from '../world/v0.2/IWorldHook.sol';
import {VectorAddress} from '../VectorAddress.sol';

struct WorldV2Storage {
    //fields populated by init function
    bool upgraded;
    address owner;
    address oldVersion;
    IWorldHook hook;
    VectorAddress baseVector;
    string name;
    uint256 nextP;
}

library LibWorldV2Storage {

    bytes32 public constant WorldStorageSlot = keccak256("_WorldV2Storage");

    function load() internal pure returns (WorldV2Storage storage ws) {
        bytes32 slot = WorldStorageSlot;
        assembly {
            ws.slot := slot
        }
    }

}
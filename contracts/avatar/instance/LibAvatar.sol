// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibStorageSlots} from '../../libraries/LibStorageSlots.sol';

struct AvatarStorage {
    bool canReceiveTokensOutsideExperience;
    address currentExperience;
    mapping(address => uint256) companyNonces;
    uint256 ownerNonce;
    bytes appearanceDetails;
}

library LibAvatar {

    function load() internal pure returns (AvatarStorage storage ds) {
        bytes32 slot = LibStorageSlots.AVATAR_STORAGE;
        assembly {
            ds.slot := slot
        }
    }

}
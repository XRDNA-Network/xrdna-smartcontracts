// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "hardhat/console.sol";

struct MixinEntry {
    function(address) internal view returns (bool) protectionVerification;
    address target;
}
struct MixinStorage {
    mapping(bytes4 => MixinEntry) targets;
}

library LibMixin {

    bytes32 constant MIXIN_STORAGE_SLOT = keccak256("_MixinStorage");

    function load() internal pure returns (MixinStorage storage ms) {
        bytes32 slot = MIXIN_STORAGE_SLOT;
        assembly {
            ms.slot := slot
        }
    }

    function addMixin(MixinStorage storage ms, bytes4 sel, address impl, function(address) internal view returns (bool) protection) internal {
        ms.targets[sel] = MixinEntry({
            protectionVerification: protection,
            target: impl
        });
    }

    function callTarget(MixinStorage storage ms, bytes4 sel, bytes calldata data) internal returns (bytes memory) {
        MixinEntry storage entry = ms.targets[sel];
        address target = entry.target;
        require(target != address(0), "Mixin: target not found");
        bool success;
        bytes memory returnData;


        // Verify the operation is allowed by the verifier function
        success = entry.protectionVerification(msg.sender);

        require(success, "Operation not allowed");
        

        // Perform delegatecall using assembly
        assembly {
            // Load the free memory pointer
            let freePtr := mload(0x40)

            // Copy the data to memory starting at the free pointer
            calldatacopy(freePtr, data.offset, data.length)

            // Perform the delegatecall
            success := delegatecall(
                gas(),
                target,           // Address of the target contract
                freePtr,          // Pointer to the input data
                data.length,      // Length of the input data
                0,                // No need to allocate memory for output data now
                0                 // No need to allocate memory for output data now
            )
            
            // Check if the call was successful
            let returnDataSize := returndatasize()
            returnData := mload(0x40)       // Set returnData to the current free memory pointer
            mstore(returnData, returnDataSize) // Store the length of the return data
            returndatacopy(add(returnData, 0x20), 0, returnDataSize) // Copy the return data

            // Update the free memory pointer
            mstore(0x40, add(returnData, add(returnDataSize, 0x20)))

            // If the call failed, revert with the return data
            if iszero(success) {
                revert(add(returnData, 0x20), returnDataSize)
            }
        }
        
        return returnData;
    }
}
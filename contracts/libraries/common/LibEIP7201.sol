// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

library LibEIP7201 {

    function generateStorageId(string memory name) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                uint256(
                    keccak256(
                        bytes(name)
                    )
                ) - 1
            )
        ) & bytes32(uint256(0xff));
    }
}
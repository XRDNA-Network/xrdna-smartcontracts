// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "hardhat/console.sol";

struct VectorAddress {
    string  x;
    string  y;
    string  z;
    uint256  t;
    uint256  p;
    uint256  p_sub;
}

library LibVectorAddress {
    using MessageHashUtils for bytes;

    function toVectorAddress(string memory x, string memory y, string memory z, uint256 t, uint256 p, uint256 p_sub) internal pure returns (VectorAddress memory) {
        return VectorAddress(x, y, z, t, p, p_sub);
    }

    function incrementP(VectorAddress memory self) internal pure returns (VectorAddress memory) {
        return VectorAddress(self.x, self.y, self.z, self.t, self.p + 1, self.p_sub);
    }

    function incrementPSub(VectorAddress memory self) internal pure returns (VectorAddress memory) {
        return VectorAddress(self.x, self.y, self.z, self.t, self.p, self.p_sub + 1);
    }

    function asLookupKey(VectorAddress memory self) internal pure returns (string memory) {
        return string.concat(
            self.x, 
            self.y, 
            self.z, 
            Strings.toString(self.t), 
            Strings.toString(self.p), 
            Strings.toString(self.p_sub));
    }

    function getSigner(VectorAddress memory self, bytes memory signature) internal pure returns (address) {
        string memory asKey = asLookupKey(self);
        //NOTE: have to convert the bytes32 to bytes in order for message hash 
        //prefix to match what's being done off-chain.
        bytes32 hash = keccak256(bytes(asKey));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        return ECDSA.recover(sigHash, signature);
    }

}
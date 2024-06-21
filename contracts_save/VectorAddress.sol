// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * @title VectorAddress
 * @dev A struct representing a vector address. A vector address is a unique identifier 
 * referencing a virtual spatial address. It is composed of a 3D vector (x, y, z) and 
 * temporal value (t), a planar value (p), and a dimension within the plane (p_sub). 
 * Worlds are given a base vector address by a Registrar, who obtains the address from
 * XRDNA as the address authority. Worlds then assign sub-locations within their world
 * to companies, which increments the planar value (p) within the world. Companies can
 * then assign sub-planar locations (p_sub) to experiences within their company and outer 
 * world. 
 * 
 * This means an experience vector address can be mapped back to its company and world
 * by setting its p_sub value to 0 and p value to 0 respectively.
 */
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

    /**
     * @dev Returns a string representation of the vector address. This is used to hash
     * the vector address and/or use it as a key in a map
     */
    function asLookupKey(VectorAddress memory self) internal pure returns (string memory) {
        return string.concat(
            self.x, 
            self.y, 
            self.z, 
            Strings.toString(self.t), 
            Strings.toString(self.p), 
            Strings.toString(self.p_sub));
    }

    /**
     * @dev Returns true if the two vector addresses are equal
     */
    function equals(VectorAddress memory self, VectorAddress memory other) internal pure returns (bool) {
        return keccak256(abi.encodePacked(asLookupKey(self))) == keccak256(abi.encodePacked(asLookupKey(other)));
    }

    /**
     * @dev Returns the address of the signer of the vector address. The signer is the 
     * registrar that assigned the vector address to the world.
     */
    function getSigner(VectorAddress memory self, address registrar, bytes memory signature) internal pure returns (address) {
        string memory asKey = asLookupKey(self);

        //it's important to include the registrar in the signature. Otherwise, 
        //a malicious actor could attempt to use a vector address not assigned to them
        bytes memory merged = abi.encode(asKey, registrar);

        
        //NOTE: have to convert the bytes32 to bytes in order for message hash 
        //prefix to match what's being done off-chain.
        bytes32 hash = keccak256(merged);
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        return ECDSA.recover(sigHash, signature);
    }

}
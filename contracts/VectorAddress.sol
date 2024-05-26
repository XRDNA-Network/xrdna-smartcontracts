// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Strings.sol";

struct VectorAddress {
    string  x;
    string  y;
    string  z;
    uint256  t;
    uint256  p;
    uint256  p_sub;
}

library LibVectorAddress {
    
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

}
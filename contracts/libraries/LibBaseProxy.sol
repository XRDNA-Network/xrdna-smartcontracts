// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

struct BaseProxyStorage {
    address implementation;
    mapping(bytes32 => mapping(address => bool)) roles;
}

library LibBaseProxy {

     bytes32 public constant BaseStorageSlot = keccak256("_BaseStorage");
     

    function load() internal pure returns (BaseProxyStorage storage bs) {
        bytes32 slot = BaseStorageSlot;
        assembly {
            bs.slot := slot
        }
    }
}

library LibProxyAccess {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    function hasRole(BaseProxyStorage storage bs, bytes32 role, address signer) internal view returns (bool) {
        return bs.roles[role][signer];
    }

    function grantRole(BaseProxyStorage storage bs, bytes32 role, address signer) internal {
        bs.roles[role][signer] = true;
    }

    function revokeRole(BaseProxyStorage storage bs, bytes32 role, address signer) internal {
       delete bs.roles[role][signer];
    }

}
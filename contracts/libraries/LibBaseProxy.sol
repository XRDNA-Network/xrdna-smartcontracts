// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

/**
 * @dev Storage data for BaseProxy
 */
struct BaseProxyStorage {
    //the current proxy's implementation contract
    address implementation;

    //mapping of roles to admins, signers
    mapping(bytes32 => mapping(address => bool)) roles;
}

/**
 * @dev Library for loading BaseProxyStorage
 */
library LibBaseProxy {

     bytes32 public constant BaseStorageSlot = keccak256("_BaseProxyStorage");
     
    /**
        * @dev Load BaseProxyStorage from storage
    */
    function load() internal pure returns (BaseProxyStorage storage bs) {
        bytes32 slot = BaseStorageSlot;
        assembly {
            bs.slot := slot
        }
    }
}

/**
 * @dev Library for accessing security roles for base proxy
 */
library LibProxyAccess {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    /**
        * @dev Check if addrss has a role
    */
    function hasRole(BaseProxyStorage storage bs, bytes32 role, address signer) internal view returns (bool) {
        return bs.roles[role][signer];
    }

    /**
     * @dev Grant a role to an address
     */
    function grantRole(BaseProxyStorage storage bs, bytes32 role, address signer) internal {
        bs.roles[role][signer] = true;
    }

    /**
     * @dev Revoke a role from an address
     */
    function revokeRole(BaseProxyStorage storage bs, bytes32 role, address signer) internal {
       delete bs.roles[role][signer];
    }

}
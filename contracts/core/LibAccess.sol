// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibRoles} from "./LibRoles.sol";

struct AccessStorage {
    address owner;
    mapping(bytes32 => mapping(address => bool)) fixedRoles;
    mapping(bytes32 => mapping(address => bool)) revokableRoles;
}
library LibAccess {


    //see EIP-7201
    bytes32 constant STORAGE_SLOT = keccak256(abi.encode(uint256(keccak256(bytes('xr.access.v1.storage'))) - 1)) & bytes32(uint256(0xff));

    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    function load() internal pure returns (AccessStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            ds.slot := slot
        }
    }

    function owner() external view returns (address) {
        AccessStorage storage ds = load();
        return ds.owner;
    }

    function setOwner(address newOwner) external {
        require(newOwner != address(0), "LibAccess: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        //allow zero address to unset owner privately
        AccessStorage storage ds = load();
        address old = ds.owner;
        ds.owner = newOwner;
        ds.fixedRoles[LibRoles.ROLE_OWNER][newOwner] = true;
        ds.fixedRoles[LibRoles.ROLE_ADMIN][newOwner] = true;
        emit OwnerChanged(old, newOwner);
    }

    /**
        * @dev Returns true if the account has the role.
     */
    function hasRole(bytes32 role, address account) external view returns (bool) {
        return _hasRole(role, account);
    }


    /**
        * @dev Grants a revokable role to an account.
     */
    function grantRole(bytes32 role, address account) external {
        _grantRevokableRole(role, account);
    }

    /**
        * @dev Revokes a role from an account.
     */
    function revokeRole(bytes32 role, address account) external {
        require(account != address(0), "LibAccess: cannot revoke role with zero address");
        AccessStorage storage ds = load();
        delete ds.revokableRoles[role][account];
        emit RoleRevoked(role, account);
    }


    function _hasRole(bytes32 role, address account) internal view returns (bool) {
        AccessStorage storage ds = load();
        return ds.fixedRoles[role][account] || ds.revokableRoles[role][account];
    }

    //fixed roles are only possible internally (i.e. contract refs, etc)
    function _grantFixedRole(bytes32 role, address account) internal {
        require(account != address(0), "LibAccess: cannot grant role with zero address");
        AccessStorage storage ds = load();
        ds.fixedRoles[role][account] = true;
        emit RoleGranted(role, account);
    }

    function _grantRevokableRole(bytes32 role, address account) internal {
        require(account != address(0), "LibAccess: cannot grant role with zero address");
        AccessStorage storage ds = load();
        ds.revokableRoles[role][account] = true;
        emit RoleGranted(role, account);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibRoles} from './LibRoles.sol';
import {LibStorageSlots} from './LibStorageSlots.sol';
import {IAccessControl} from '../interfaces/IAccessControl.sol';

 
struct AccessStorage {
    //the primary owner of the contract
    address owner;

    //roles mapped to addresses that have the role
    mapping(bytes32 => mapping(address => bool)) roles;
}

/**
 * @title LibAccess
 * @dev Access control logic is not likely to change or be upgradeable. It is, however, a highly used library
 * that incurs a lot of gas costs to maintain as a separate module. Early dev version used an access module
 * and it proved to add too much overhead for just verifying access. So it was moved into this library to
 * reduce gas costs and simplify the codebase.
 */

library LibAccess {

    function load() internal pure returns (AccessStorage storage a) {
        bytes32 slot = LibStorageSlots.ACCESS_STORAGE;
        assembly {
            a.slot := slot
        }
    }

    /**
     * @dev Initializes the access control contract with an owner and a list of admins. Owners
     * and admins are also given signing privileges.
     */
    function initAccess(address _owner, address[] calldata admins) external {
        AccessStorage storage s = load();
        require(s.owner == address(0), "Already initialized");
        require(_owner != address(0), "Owner cannot be zero address");
        s.owner = _owner;

        //access primary map once time for each role type to save gas
        mapping(address => bool) storage ownerRoles = s.roles[LibRoles.ROLE_OWNER];
        mapping(address => bool) storage adminRoles = s.roles[LibRoles.ROLE_ADMIN];
        mapping(address => bool) storage signerRoles = s.roles[LibRoles.ROLE_SIGNER];

        //set owner privs
        ownerRoles[_owner] = true;
        adminRoles[_owner] = true;
        signerRoles[_owner] = true;
        emit IAccessControl.OwnerChanged(address(0), _owner);
        emit IAccessControl.RoleChanged(LibRoles.ROLE_ADMIN, _owner, true);
        emit IAccessControl.RoleChanged(LibRoles.ROLE_SIGNER, _owner, true);
        for(uint256 i=0;i<admins.length;++i) {
            //set admin privs
            require(admins[i] != address(0), "Admins cannot be zero address");
            adminRoles[admins[i]] = true;
            emit IAccessControl.RoleChanged(LibRoles.ROLE_ADMIN, admins[i], true);
            signerRoles[admins[i]] = true;
            emit IAccessControl.RoleChanged(LibRoles.ROLE_SIGNER, admins[i], true);
        }
    }

    /**
     * @dev Returns the owner of the contract.
     */
    function owner() internal view returns (address) {
        AccessStorage storage s = load();
        return s.owner;
    }

    /**
     * @dev Sets the owner of the contract. Should only be called by the current owner.
     */
    function setOwner(address o) external {
        require(o != address(0), "AccessControl: cannot set owner to zero address");
        AccessStorage storage s = load();
        s.owner = o;
        s.roles[LibRoles.ROLE_OWNER][o] = true;
        s.roles[LibRoles.ROLE_ADMIN][o] = true;
        emit IAccessControl.OwnerChanged(owner(), o);
    }

    /**
     * @dev Adds a list of admins to the contract. Should only be called by an admin
     */
    function addSigners(address[] calldata signers) external {
        AccessStorage storage s = load();
        mapping(address => bool) storage signerRoles = s.roles[LibRoles.ROLE_SIGNER];
        for(uint256 i=0;i<signers.length;++i) {
            require(signers[i] != address(0), "SharedLibAccess: cannot add zero address signers");
            signerRoles[signers[i]] = true;
            emit IAccessControl.RoleChanged(LibRoles.ROLE_SIGNER, signers[i], true);
        }
    }

    /**
     * @dev Removes a list of admins from the contract. Should only be called by an admin
     */
    function removeSigners(address[] calldata signers) external {
        AccessStorage storage s = load();
        mapping(address => bool) storage signerRoles = s.roles[LibRoles.ROLE_SIGNER];
        for(uint256 i=0;i<signers.length;++i) {
            require(signers[i] != address(0), "SharedLibAccess: cannot remove zero address signers");
            delete signerRoles[signers[i]];
            emit IAccessControl.RoleChanged(LibRoles.ROLE_SIGNER, signers[i], false);
        }
    }

    /**
     * @dev Returns true if the given address is a registered signer
     */
    function isSigner(address a) external view returns (bool) {
        AccessStorage storage s = load();
        return s.roles[LibRoles.ROLE_SIGNER][a];
    }

    /**
     * @dev Returns true if the given address is a registered admin
     */
    function isAdmin(address a) external view returns (bool) {
        AccessStorage storage s = load();
        return s.roles[LibRoles.ROLE_ADMIN][a];
    }

    /**
     * @dev Returns true if the given address has the specified role
     */
    function hasRole(bytes32 role, address account) external view returns (bool) {
        AccessStorage storage s = load();
        return s.roles[role][account];
    }

    /**
     * @dev Grants a role to an address. Should only be called by an admin.
     */
    function grantRole(bytes32 role, address account) external {
        require(account != address(0), "AccessControl: cannot grant role to zero address");
        AccessStorage storage s = load();
        s.roles[role][account] = true;
        emit IAccessControl.RoleChanged(role, account, true);
    }

    /**
     * @dev Revokes a role from an address. Should only be called by an admin.
     */
    function revokeRole(bytes32 role, address account) external {
        require(account != address(0), "AccessControl: cannot revoke role from zero address");
        AccessStorage storage s = load();
        s.roles[role][account] = false;
        emit IAccessControl.RoleChanged(role, account, false);
    }
}
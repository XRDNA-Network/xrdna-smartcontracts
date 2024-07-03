// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibRoles} from './LibRoles.sol';
import {LibStorageSlots} from './LibStorageSlots.sol';

 
struct AccessStorage {
    address owner;
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

    modifier onlyAdmin {
        require(load().roles[LibRoles.ROLE_ADMIN][msg.sender], "AccessModule: only admin allowed");
        _;
    }

    modifier onlyOwner {
        require(load().owner == msg.sender, "AccessModule: only owner allowed");
        _;
    }

    function initAccess(address _owner, address[] calldata admins) external {
        AccessStorage storage s = load();
        require(s.owner == address(0), "Already initialized");
        require(_owner != address(0), "Owner cannot be zero address");
        s.owner = _owner;
        s.roles[LibRoles.ROLE_OWNER][_owner] = true;
        s.roles[LibRoles.ROLE_ADMIN][_owner] = true;
        s.roles[LibRoles.ROLE_SIGNER][_owner] = true;
        for(uint256 i=0;i<admins.length;++i) {
            require(admins[i] != address(0), "Admins cannot be zero address");
            s.roles[LibRoles.ROLE_ADMIN][admins[i]] = true;
            s.roles[LibRoles.ROLE_SIGNER][admins[i]] = true;
        }
    }

    function owner() external view returns (address) {
        AccessStorage storage s = load();
        return s.owner;
    }

    function setOwner(address o) external onlyOwner {
        require(o != address(0), "AccessControl: cannot set owner to zero address");
        AccessStorage storage s = load();
        s.owner = o;
        s.roles[LibRoles.ROLE_OWNER][o] = true;
        s.roles[LibRoles.ROLE_ADMIN][o] = true;
    }

    function addSigners(address[] calldata signers) external onlyAdmin {
        AccessStorage storage s = load();
        for(uint256 i=0;i<signers.length;++i) {
            require(signers[i] != address(0), "SharedLibAccess: cannot add zero address signers");
            s.roles[LibRoles.ROLE_SIGNER][signers[i]] = true;
        }
    }

    function removeSigners(address[] calldata signers) external onlyAdmin {
        AccessStorage storage s = load();
        for(uint256 i=0;i<signers.length;++i) {
            require(signers[i] != address(0), "SharedLibAccess: cannot remove zero address signers");
            s.roles[LibRoles.ROLE_SIGNER][signers[i]] = false;
        }
    }

    function isSigner(address a) external view returns (bool) {
        AccessStorage storage s = load();
        return s.roles[LibRoles.ROLE_SIGNER][a];
    }

    function isAdmin(address a) external view returns (bool) {
        AccessStorage storage s = load();
        return s.roles[LibRoles.ROLE_ADMIN][a] || s.roles[LibRoles.ROLE_OWNER][a];
    }

    function hasRole(bytes32 role, address account) external view returns (bool) {
        AccessStorage storage s = load();
        return s.roles[role][account];
    }

    function grantRole(bytes32 role, address account) external onlyAdmin {
        require(account != address(0), "AccessControl: cannot grant role to zero address");
        AccessStorage storage s = load();
        s.roles[role][account] = true;
        require(s.roles[role][account], "AccessControl: failed to grant role");
    }

    function revokeRole(bytes32 role, address account) external onlyAdmin {
        require(account != address(0), "AccessControl: cannot revoke role from zero address");
        AccessStorage storage s = load();
        s.roles[role][account] = false;
    }

}
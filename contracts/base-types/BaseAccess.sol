// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAccessControl} from '../interfaces/IAccessControl.sol';
import {LibAccess} from '../libraries/LibAccess.sol';

abstract contract BaseAccess is IAccessControl {

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), 'BaseAccess: restricted to admins');
        _;
    }

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, 'BaseAccess: restricted to owner');
        _;
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return LibAccess.hasRole(role, account);
    }

    function grantRole(bytes32 role, address account) public onlyAdmin {
        LibAccess.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public onlyAdmin {
        LibAccess.revokeRole(role, account);
    }

    function addSigners(address[] calldata signers) public onlyAdmin {
        LibAccess.addSigners(signers);
    }

    function removeSigners(address[] calldata signers) public onlyAdmin {
        LibAccess.removeSigners(signers);
    }

    function isSigner(address account) public view returns (bool) {
        return LibAccess.isSigner(account);
    }

    function isAdmin(address account) public view returns (bool) {
        return LibAccess.isAdmin(account);
    }

    function owner() public view returns (address) {
        return LibAccess.owner();
    }

    function changeOwner(address newOwner) public onlyOwner {
        LibAccess.setOwner(newOwner);
    }

    function initAccess(address o, address[] calldata admins) internal {
        LibAccess.initAccess(o, admins);
    }
}
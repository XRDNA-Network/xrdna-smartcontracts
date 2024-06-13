// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {BaseProxyStorage, LibProxyAccess, LibBaseProxy} from './libraries/LibBaseProxy.sol';
import {IBaseAccess} from './IBaseAccess.sol';

/**
 * @dev Base contract for access control held in version-bases storage (i.e. not AccessControl 
 * from OpenZeppelin Contracts). This contract is meant to be inherited by other contracts that
 * store role information in versioned storage structs.
 */
abstract contract BaseAccess is IBaseAccess {
    using LibProxyAccess for BaseProxyStorage;

    modifier onlyRole(bytes32 role) {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        require(bs.hasRole(role, msg.sender), "BaseProxy: caller does not have required role");
        _;
    }

    modifier onlyAdmin() {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        require(bs.hasRole(LibProxyAccess.ADMIN_ROLE, msg.sender), "BaseAccess: caller does not have admin role");
        _;
    }

    modifier onlySigner() {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        require(bs.hasRole(LibProxyAccess.SIGNER_ROLE, msg.sender), "BaseAccess: caller does not have signer role");
        _;
    }

    /**
      * @dev add signing authorities to the contract. Only the admin role can do this.
     */
    function addSigners(address[] calldata signers) external override onlyAdmin {
        _addSigners(signers);
    }

    //internally used to add signers to the contract when admin not yet assigned
    function _addSigners(address[] calldata signers) internal {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        for (uint256 i = 0; i < signers.length; i++) {
            require(signers[i] != address(0), "BaseProxy: signer is zero address");
            bs.grantRole(LibProxyAccess.SIGNER_ROLE, signers[i]);
            emit SignerAdded(signers[i]);
        }
    }

    /**
     * @dev remove signers from the contract. only admin can do this.
     */
    function removeSigners(address[] calldata signers) external override onlyAdmin {
        _removeSigners(signers);
    }

    //internally remove signers when admin not required
    function _removeSigners(address[] calldata signers) internal {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        for (uint256 i = 0; i < signers.length; i++) {
            bs.revokeRole(LibProxyAccess.SIGNER_ROLE, signers[i]);
            emit SignerRemoved(signers[i]);
        }
    }

    /**
     * @dev check if an address is a signer
     */
    function isSigner(address signer) external view override returns (bool) {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        return bs.hasRole(LibProxyAccess.SIGNER_ROLE, signer);
    }
}
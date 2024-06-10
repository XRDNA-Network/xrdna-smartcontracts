// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {BaseProxyStorage, LibProxyAccess, LibBaseProxy} from './libraries/LibBaseProxy.sol';
import {IBaseAccess} from './IBaseAccess.sol';

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

    function addSigners(address[] calldata signers) external override onlyAdmin {
        _addSigners(signers);
    }

    function _addSigners(address[] calldata signers) internal {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        for (uint256 i = 0; i < signers.length; i++) {
            require(signers[i] != address(0), "BaseProxy: signer is zero address");
            bs.setRole(LibProxyAccess.SIGNER_ROLE, signers[i], true);
            emit SignerAdded(signers[i]);
        }
    }

    function removeSigners(address[] calldata signers) external override onlyAdmin {
        _removeSigners(signers);
    }

    function _removeSigners(address[] calldata signers) internal {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        for (uint256 i = 0; i < signers.length; i++) {
            bs.setRole(LibProxyAccess.SIGNER_ROLE, signers[i], false);
            emit SignerRemoved(signers[i]);
        }
    }

    function isSigner(address signer) external view override returns (bool) {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        return bs.hasRole(LibProxyAccess.SIGNER_ROLE, signer);
    }
}
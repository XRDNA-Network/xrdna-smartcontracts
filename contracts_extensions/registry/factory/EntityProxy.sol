// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IEntityProxy} from "./interfaces/IEntityProxy.sol";
import {ProxyStorage, LibProxy} from '../libraries/LibProxy.sol';
import {LibAccess} from '../../core/LibAccess.sol';
import {LibRoles} from '../../core/LibRoles.sol';
import {IEntityFactory} from './interfaces/IEntityFactory.sol';

contract EntityProxy is IEntityProxy {

    address public immutable factory;

    modifier onlyFactory {
        require(msg.sender == factory, "EntityProxy: only factory allowed");
        _;
    }

    modifier onlyAdmin {
        require(LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "EntityProxy: only admin allowed");
        _;
    }

    constructor(address _factory) {
        require(_factory != address(0), "EntityProxy: factory is the zero address");
        factory = _factory;
    }

    receive() external payable {}

    function setImplementation(address _newImplementation, uint256 version) external onlyFactory {
        require(_newImplementation != address(0), "EntityProxy: implementation is the zero address");
        ProxyStorage storage ps = LibProxy.load();
        ps.implementation = _newImplementation;
        ps.version = version;
        emit EntityImplementationChanged(_newImplementation, version);
    }

    function setAutomaticUpgrade(bool _alwaysUseLatest) external onlyAdmin {
        LibProxy.load().alwaysUseLatest = _alwaysUseLatest;
    }

    function isAutomaticUpgrade() external view returns (bool) {
        return LibProxy.load().alwaysUseLatest;
    }

    function implementationVersion() external view returns (uint256) {
        return LibProxy.load().version;
    }

    function _getImpl() internal returns (address) {
        ProxyStorage storage ps = LibProxy.load();
        if (ps.alwaysUseLatest) {
            uint256 v = IEntityFactory(ps.factory).currentImplVersion();
            if (v > ps.version) {
                ps.version = v;
                ps.implementation = IEntityFactory(ps.factory).getImplementation();
                emit EntityImplementationChanged(ps.implementation, v);
            }
        }
        return ps.implementation;
    }

    fallback() external {
        address _impl = _getImpl();
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
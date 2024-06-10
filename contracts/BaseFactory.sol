// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';

abstract contract BaseFactory is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address implementation;
    address proxyImplementation;
    address authorizedRegistry;

    event AuthorizedRegistryChanged(address indexed oldRegistry, address indexed newRegistry);
    
    modifier onlyAuthorizedRegistry {
        require(authorizedRegistry != address(0), "BaseFactory: authorized registry not set");
        require(msg.sender == authorizedRegistry, "BaseFactory: caller is not authorized registry");
        _;
    }

    constructor(address mainAdmin, address[] memory admins) {
        require(mainAdmin != address(0), "BaseFactory: main admin cannot be zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, mainAdmin);
        _grantRole(ADMIN_ROLE, mainAdmin);
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "BaseFactory: admin cannot be zero address");
            _grantRole(ADMIN_ROLE, admins[i]);
        }
    }

    function setProxyImplementation(address _proxyImplementation) public onlyRole(ADMIN_ROLE) {
        require(_proxyImplementation != address(0), "BaseFactory: proxy implementation cannot be zero address");
        proxyImplementation = _proxyImplementation;
    }

    function setImplementation(address _implementation) public onlyRole(ADMIN_ROLE) {
        require(_implementation != address(0), "BaseFactory: implementation cannot be zero address");
        implementation = _implementation;
        
    }

    function setAuthorizedRegistry(address _registry) public onlyRole(ADMIN_ROLE) {
        require(_registry != address(0), "WorldFactory: registry cannot be zero address");
        authorizedRegistry = _registry;
        emit AuthorizedRegistryChanged(authorizedRegistry, _registry);
    }

    function createProxy() internal returns (address) {
        require(proxyImplementation != address(0), "BaseFactory: proxy implementation not set");
        return create(proxyImplementation);
    }

    function create() internal returns (address) {
        return create(implementation);
    }

    function create(address impl) internal returns (address proxy){
        require(impl != address(0), "BaseFactory: implementation not set");
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(impl);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
    }

    function isClone(address query) public view returns (bool result) {
        bytes20 targetBytes = bytes20(implementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}
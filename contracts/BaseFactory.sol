// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IBaseFactory} from './IBaseFactory.sol';

/**
 * @title BaseFactory
 * @dev Base factory contract that provides common functionality for creating and upgrading
 * contracts. It handles cloning logic for both concrete implementations and proxies.
 */
abstract contract BaseFactory is IBaseFactory, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address implementation;
    address proxyImplementation;
    address authorizedRegistry;
    uint256 public override supportsVersion;

    event AuthorizedRegistryChanged(address indexed oldRegistry, address indexed newRegistry);
    
    modifier onlyAuthorizedRegistry {
        require(authorizedRegistry != address(0), "BaseFactory: authorized registry not set");
        require(msg.sender == authorizedRegistry, "BaseFactory: caller is not authorized registry");
        _;
    }

    /**
     * @dev Initializes the contract with the main admin (role assigner) and a list of 
     * admins (can only change factory)
     */
    constructor(address mainAdmin, address[] memory admins) {
        require(mainAdmin != address(0), "BaseFactory: main admin cannot be zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, mainAdmin);
        _grantRole(ADMIN_ROLE, mainAdmin);
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "BaseFactory: admin cannot be zero address");
            _grantRole(ADMIN_ROLE, admins[i]);
        }
    }

    /**
     * @dev sets the proxy implementation address to use for cloning proxy instances. Only 
     * admins can update the implementation.
     */
    function setProxyImplementation(address _proxyImplementation) public onlyRole(ADMIN_ROLE) {
        require(_proxyImplementation != address(0), "BaseFactory: proxy implementation cannot be zero address");
        proxyImplementation = _proxyImplementation;
    }

    /**
     * @dev returns the current proxy implementation address.
     */
    function getProxyImplementation() public view returns (address) {
        return proxyImplementation;
    }

    /**
     * @dev sets the implementation address to use for cloning instances along
     * with the version corresponding to the new implementation.
     * Only admins can update the implementation.
     */
    function setImplementation(address _implementation, uint256 version) public onlyRole(ADMIN_ROLE) {
        require(_implementation != address(0), "BaseFactory: implementation cannot be zero address");
        require(version > supportsVersion, "BaseFactory: version must be greater than current version");
        require(implementation != _implementation, "BaseFactory: implementation already set");
        implementation = _implementation;
        supportsVersion = version;
    }

    /**
     * @dev returns the current implementation address.
     */
    function getImplementation() public view returns (address) {
        return implementation;
    }

    /**
        * @dev sets the authorized registry address that can call the public create functions.
     */
    function setAuthorizedRegistry(address _registry) public onlyRole(ADMIN_ROLE) {
        require(_registry != address(0), "WorldFactory: registry cannot be zero address");
        authorizedRegistry = _registry;
        emit AuthorizedRegistryChanged(authorizedRegistry, _registry);
    }

    /**
     * Create a new cloned instance of the proxy impl.
     */
    function createProxy() internal returns (address) {
        require(proxyImplementation != address(0), "BaseFactory: proxy implementation not set");
        return create(proxyImplementation);
    }

    /**
     * @dev Create a new cloned instance of the implementation.
     */
    function create() internal returns (address) {
        return create(implementation);
    }

    /**
     * @dev Create a new cloned instance of the given implementation.
     */
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
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibAccess} from '../libraries/LibAccess.sol';
import {LibStorageSlots} from '../libraries/LibStorageSlots.sol';
import {Version} from '../libraries/LibVersion.sol';

//interface to get version from implementation contract
interface IProvidesVersion {
    function version() external view returns (Version memory);
}

/**
 * storage for proxy
 */
struct ProxyStorage {
    address implementation;
    Version version;
}

/**
 * @dev constructor args for base proxy
 */
struct BaseProxyConstructorArgs {
    //initial implementation
    address impl;

    //owner for this contract
    address owner;

    //admins to assign to the contract
    address[] admins;
}

/**
 * @title BaseProxy
 * @dev Base proxy for all non-entity proxy contracts.
 */
abstract contract BaseProxy {

    modifier onlyOwner() {
        require(LibAccess.owner() == msg.sender, "EntityProxy: restricted to owner");
        _;
    }

    constructor(BaseProxyConstructorArgs memory args) {
        address impl = args.impl;
        require(impl != address(0), "EntityProxy: implementation is zero address");
        ProxyStorage storage ps = load();

        //set the implementation logic to use
        ps.implementation = impl;

        //set the intiaial version of the proxy's logic
        ps.version = IProvidesVersion(impl).version();

        //initialize access controls
        LibAccess.initAccess(args.owner, args.admins);
    }

    receive() external payable {}

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "EntityProxy: insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    //storage loader
    function load() internal pure returns (ProxyStorage storage ps) {
        bytes32 slot = LibStorageSlots.ENTITY_PROXY_STORAGE;
        assembly {
            ps.slot := slot
        }
    }

    /**
     * @dev set the implementation contract to use for the proxy. Only the owner can change
     * the logic contract which ultimately changes the behavior of the contract. The storage
     * will remain in-tact but the logic will change. Note that all storage must be compatible
     * with newer and older versions of the logic contract. Older versions meaning if there is a 
     * rollback, the storage must remaining compatible with the older logic contract as well as any
     * new version.
     */
    function setImplementation(address _implementation) external onlyOwner {
        Version memory version = IProvidesVersion(_implementation).version();
        ProxyStorage storage ps = load();
        ps.implementation = _implementation;
        ps.version = version;
    }

    /**
     * @dev get the implementation contract for the proxy
     */
    function getImplementation() external view returns (address) {
        ProxyStorage storage ps = load();
        return ps.implementation;
    }

    /**
     * @dev get the version of the implementation contract
     */
    function getVersion() external view returns (Version memory) {
        ProxyStorage storage ps = load();
        return ps.version;
    }

    /**
     * @dev fallback function to delegate execution to the implementation contract
     */
    fallback() external payable {
        ProxyStorage storage ps = load();
        address _impl = ps.implementation;
        require(_impl != address(0), "EntityProxy: implementation not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 { revert(0, returndatasize()) }
                default { return(0, returndatasize()) }
        }
    }

}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import "@openzeppelin/contracts/access/AccessControl.sol";
import {VectorAddress} from '../../VectorAddress.sol';
import {IWorldFactory} from './IWorldFactory.sol';
import {IBasicWorld} from './IWorld.sol';
//import "hardhat/console.sol";

contract WorldFactory is IWorldFactory, AccessControl {
    
    address public worldImplementation;
    address public worldRegistry;

    event WorldCreated(address indexed world);
    event WorldRegistryChanged(address indexed worldRegistry);

    modifier onlyWorldRegistry() {
        require(worldRegistry != address(0), "WorldFactory: world registry not set");
        require(msg.sender == worldRegistry, "WorldFactory: caller is not the world registry");
        _;
    }

    constructor(address[] memory admins) {
        for (uint256 i = 0; i < admins.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, admins[i]);
        }
    }

    function setImplementation(address _worldImplementation) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_worldImplementation != address(0), "WorldFactory: implementation cannot be zero address");
        worldImplementation = _worldImplementation;
        
    }

    function setWorldRegistry(address _worldRegistry) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_worldRegistry != address(0), "WorldFactory: world registry cannot be zero address");
        worldRegistry = _worldRegistry;
        emit WorldRegistryChanged(worldImplementation);
    }

    function createWorld(address owner, bytes calldata initData) public onlyWorldRegistry returns (address proxy){
        require(worldImplementation != address(0), "WorldFactory: world implementation not set");
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(worldImplementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
        IBasicWorld(proxy).init(owner, initData);
        //console.log("Calling proxy.init", address(this));
        emit WorldCreated(address(proxy));
        
    }

    function isWorldClone(address query) public view override returns (bool result) {
        bytes20 targetBytes = bytes20(worldImplementation);
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
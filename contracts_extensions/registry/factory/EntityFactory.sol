// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IEntityFactory} from "./interfaces/IEntityFactory.sol";
import {EntityFactoryStorage, LibFactory} from "../libraries/LibFactory.sol";
import {IEntityProxy} from "./interfaces/IEntityProxy.sol";
import {LibAccess} from "../../core/LibAccess.sol";
import {LibRoles} from "../../core/LibRoles.sol";
import {IRegisteredEntity} from "../../entity/interfaces/IRegisteredEntity.sol";

struct EntityFactoryConstructorArgs {
    address owner;
    address[] otherAdmins;
}

contract EntityFactory is IEntityFactory {

    modifier onlyRegistry() {
        require(msg.sender == LibFactory.load().authorizedRegistry, "EntityFactory: only registry allowed");
        _;
    }

    modifier onlyAdmin() {
        require(
            LibAccess.owner() == msg.sender ||
            LibAccess.hasRole(LibRoles.ROLE_ADMIN, msg.sender), "EntityFactory: only admin allowed");
        _;
    }

    constructor(EntityFactoryConstructorArgs memory args) {
        require(args.owner != address(0), "EntityFactory: admin cannot be zero address");
        LibAccess.setOwner(args.owner);
        for (uint256 i = 0; i < args.otherAdmins.length; i++) {
            require(args.otherAdmins[i] != address(0), "EntityFactory: admin cannot be zero address");
            LibAccess._grantRevokableRole(LibRoles.ROLE_ADMIN, args.otherAdmins[i]);
        }
    }


    function createEntity(address owner, string calldata name, bytes calldata initData) external onlyRegistry returns (address proxy) {
        EntityFactoryStorage storage ecs = LibFactory.load();
        require(ecs.proxyImplementation != address(0), "EntityFactory: proxy implementation not set");
        require(ecs.implementation != address(0), "EntityFactory: implementation not set");
        proxy = _create(ecs.proxyImplementation);
        IEntityProxy(proxy).setImplementation(ecs.implementation, ecs.version);
        IRegisteredEntity(proxy).init(owner, name, initData);
    }
    
    function setImplementation(address newImplementation, uint256 version) external onlyAdmin {
        require(newImplementation != address(0), "EntityFactory: implementation cannot be zero address");
        EntityFactoryStorage storage ecs = LibFactory.load();
        ecs.implementation = newImplementation;
        ecs.version = version;
        emit FactoryImplementationChanged(newImplementation, ecs.version);
    }

    function setProxyImplementation(address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "EntityFactory: proxy implementation cannot be zero address");
        LibFactory.load().proxyImplementation = newImplementation;
        emit FactoryProxyImplementationChanged(newImplementation);
    }

    function getImplementation() external view returns (address) {
        return LibFactory.load().implementation;
    }

    function currentImplVersion() external view returns (uint256) {
        return LibFactory.load().version;
    }

    function setAuthorizedRegistry(address registry) external onlyAdmin {
        require(registry != address(0), "EntityFactory: registry cannot be zero address");
        LibFactory.load().authorizedRegistry = registry;
    }

    function _create(address impl) internal returns (address proxy){
        require(impl != address(0), "EntityCreator: implementation not set");
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
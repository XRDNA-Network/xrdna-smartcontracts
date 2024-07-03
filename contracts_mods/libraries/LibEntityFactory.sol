// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IEntityFactory} from "../modules/entity/factory/IEntityFactory.sol";
import {ModuleVersion} from "../modules/IModule.sol";
import {LibDelegation} from '../core/LibDelegation.sol';
import "hardhat/console.sol";

interface IEntityFactoryProvider {
    function entityFactory() external view returns (IEntityFactory);
}
library LibEntityFactory {

    using LibDelegation for address;

    function _getFactory() internal view returns (IEntityFactory) {
        return IEntityFactoryProvider(address(this)).entityFactory();
    }

    function setEntityImplementation(address newImplementation) external {
        IEntityFactory entry = _getFactory();
        bytes memory data = abi.encodeWithSelector(IEntityFactory.setEntityImplementation.selector, newImplementation);
        address(entry).dCall(data);
    }

    function getEntityImplementation() external view returns (address) {
        IEntityFactory entry = _getFactory();
        bytes memory data = abi.encodeWithSelector(IEntityFactory.getEntityImplementation.selector);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (address));
    }

    function currentImplVersion() external view returns (ModuleVersion memory) {
        IEntityFactory entry = _getFactory();
        bytes memory data = abi.encodeWithSelector(IEntityFactory.currentImplVersion.selector);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (ModuleVersion));
    }

    function setProxyImplementation(address newImplementation) external {
        IEntityFactory entry = _getFactory();
        bytes memory data = abi.encodeWithSelector(IEntityFactory.setProxyImplementation.selector, newImplementation);
        address(entry).dCall(data);
    }

    function createEntity(address owner, string calldata name, bytes calldata initData) external returns (address) {
        IEntityFactory entry = _getFactory();
        bytes memory data = abi.encodeWithSelector(IEntityFactory.createEntity.selector, owner, name, initData);
        console.log("Calling createEntity on", address(entry));
        bytes memory r = address(entry).dCall(data);
        return abi.decode(r, (address));
    }

    function upgradeEntity(address entity, bytes calldata initData) external {
        IEntityFactory entry = _getFactory();
        bytes memory data = abi.encodeWithSelector(IEntityFactory.upgradeEntity.selector, entity, initData);
        address(entry).dCall(data);
    }

}
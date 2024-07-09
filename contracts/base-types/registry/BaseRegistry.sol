// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from '../../interfaces/registry/IRegistry.sol';
import {BaseAccess} from '../BaseAccess.sol';
import {LibRegistration} from '../../libraries/LibRegistration.sol';
import {LibFactory} from '../../libraries/LibFactory.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';


abstract contract BaseRegistry is BaseAccess, IRegistry {

    function setEntityImplementation(address _entityImplementation) external onlyAdmin {
        LibFactory.setEntityImplementation(_entityImplementation);
    }

    function getEntityImplementation() external view returns (address) {
        return LibFactory.getEntityImplementation();
    }

    function setProxyImplementation(address _proxyImplementation) external onlyAdmin {
        LibFactory.setProxyImplementation(_proxyImplementation);
    }

    function getProxyImplementation() external view returns (address) {
        return LibFactory.getProxyImplementation();
    }

    function getEntityVersion() external view returns (Version memory) {
        return LibFactory.getEntityVersion();
    }

    function isRegistered(address addr) external view returns (bool) {
        return LibRegistration.isRegistered(addr);
    }

    function getEntityByName(string calldata name) external view returns (address) {
        return LibRegistration.getEntityByName(name);
    }

    function _registerNonRemovableEntity(address entity) internal {
        LibRegistration.registerNonRemovableEntity(entity);
    }
}
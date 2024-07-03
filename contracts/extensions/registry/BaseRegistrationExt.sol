// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibFactory} from '../../libraries/LibFactory.sol';
import {LibExtensions, AddSelectorArgs} from '../../libraries/LibExtensions.sol';
import {IRegistration, CreateEntityArgs, ChangeEntityTermsArgs} from '../../interfaces/registry/IRegistration.sol';
import {LibRegistration} from '../../libraries/LibRegistration.sol';


abstract contract BaseRegistrationExt is IExtension, IRegistration {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "FactoryExt: restricted to admins");
        _;
    }

    modifier onlyRegisteredEntity {
        require(isRegistered(msg.sender), "RegistrationExt: only registered entities can call this function");
        _;
    }


    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no-op
    }

    /**
     * Initialize any storage related to the extension
     */
    function initStorage(ExtensionInitArgs calldata args) external {
        //nothing to initialize
    }

    function isRegistered(address addr) public view returns (bool) {
        return LibRegistration.isRegistered(addr);
    }

    function getEntityByName(string calldata name) public view returns (address) {
        return LibRegistration.getEntityByName(name);
    }

    function changeEntityTerms(ChangeEntityTermsArgs calldata args) public override {
        LibRegistration.changeEntityTerms(args);
    }

    
}
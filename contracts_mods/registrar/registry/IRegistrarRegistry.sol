// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistry} from '../../modules/registry/IRegistry.sol';
import {RegistrationTerms} from '../../modules/registration/IRegistration.sol';
import {ITermsOwner} from '../../modules/registration/ITermsOwner.sol';
import {ModuleVersion, IModule} from '../../modules/IModule.sol';
import {ICoreApp} from '../../core/ICoreApp.sol';

struct CreateRegistrarArgs {
    bool sendTokensToOwner;
    address owner;
    string name;
    bytes initData;
}

interface IRegistrarRegistry is IRegistry, ITermsOwner, ICoreApp {

    event RegistryAddedRegistrar(address indexed registrarContract, address indexed owner);
    event RegistryDeactivatedRegistrar(address indexed registrarContract);
    event RegistryReactivatedRegistrar(address indexed registrarContract);
    event RegistryRemovedRegistrar(address indexed registrarContract);
    event RegistryUpgradedRegistrar(address indexed registrarContract, address newVersion);

    event RegistryChangedEntityRemovalLogic(address indexed removalModule);
    event RegistryChangedEntityFactory(address indexed factory);
    event RegistryChangedRegistrationLogic(address indexed registration);

    function setEntityRemovalLogic(address removalModule) external;
    function entityRemovalLogic() external view returns (address);

    function setEntityFactory(address factory) external;
    function entityFactory() external view returns (address);

    function setRegistrationLogic(address registration) external;
    function registrationLogic() external view returns (address);

    function createRegistrar(CreateRegistrarArgs calldata args) external payable returns (address);
    function version() external pure override(ICoreApp,IModule) returns (ModuleVersion memory);

}
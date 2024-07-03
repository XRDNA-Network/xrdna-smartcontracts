// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct ModuleVersion {
    uint16 major;
    uint16 minor;
}

/**
 * @title IModule
 * @dev Interface for modules. Modules are the logic of an application. They can be upgraded and rolled back 
 * to change the application's behavior or fix bugs. Modules are delegatecalled by an application and thus 
 * have no security controls. They merely provide the logic to change the application's state.
 */
interface IModule {

    /**
     * @dev The globally unique name of the module. This is the same as the primary interface the module 
     * implements.
     */
    function name() external view returns (string memory);

    /**
     * @dev The version of the module. This is used to check compatibility for upgrades or rollbacks.
     */
    function version() external view returns (ModuleVersion memory);
}
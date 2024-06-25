// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {CoreShell, CoreShellConstructorArgs} from "../../core/CoreShell.sol";
import {IRegistrarRegistry} from "../interfaces/IRegistrarRegistry.sol";
import {IEntityFactory} from "../../registry/factory/interfaces/IEntityFactory.sol";
import {LibAccess} from "../../core/LibAccess.sol";
import {LibRoles} from "../../core/LibRoles.sol";
import {RegistrationTerms} from "../../registry/extensions/registration/interfaces/IRegistration.sol";
import {LibExtensions} from "../../core/LibExtensions.sol";
import {LibTermsOwner} from '../../entity/libraries/LibTermsOwner.sol';

struct RegistrarRegistryConstructorArgs {
    address owner; //can be zero
    address[] otherAdmins; //can be empty
    address extensionManager;
    address entityCreator;
    RegistrationTerms registrarTerms;
}

contract RegistrarRegistry is CoreShell, IRegistrarRegistry {

    IEntityFactory public immutable entityFactory;

    constructor(RegistrarRegistryConstructorArgs memory args) CoreShell(CoreShellConstructorArgs({
        owner: args.owner,//can be zero
        otherAdmins: args.otherAdmins, //can be empty
        extensionManager: args.extensionManager   
    })) {
        require(args.entityCreator != address(0), "EntityCreator cannot be zero address");
        entityFactory = IEntityFactory(args.entityCreator);
        //set terms for terms owner extension
        LibTermsOwner.load().terms = args.registrarTerms;

        //already checked zero-address in CoreShell
        LibAccess._grantRevokableRole(LibRoles.ROLE_SIGNER, args.owner);
        for(uint256 i = 0; i < args.otherAdmins.length; i++) {
            //already checked zero-address in CoreShell
            LibAccess._grantRevokableRole(LibRoles.ROLE_SIGNER, args.otherAdmins[i]);
        }
    }

    function createEntityInstance(address owner, string calldata name, bytes calldata initData) public override returns (address) {
        return entityFactory.createEntity(owner, name, initData);
    }

    function isActiveTermsOwner(address caller) external view override returns (bool) {
        //only registry signers are authorized to do anything with registrars.
        return LibAccess.hasRole(LibRoles.ROLE_SIGNER, caller) ||
            LibAccess.hasRole(LibRoles.ROLE_ADMIN, caller) ||
            LibAccess.owner() == caller;
    }

    function isActive() external pure returns (bool) {
        //this registry, as the terms owner, can never be inactive
        return true;
    }

    function isSigner(address _signer) external view override returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_SIGNER, _signer);
    }
}
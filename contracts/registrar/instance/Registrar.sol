// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {CoreShell, CoreShellConstructorArgs} from "../../core/CoreShell.sol";
import {IRegistrar} from "../interfaces/IRegistrar.sol";
import {EntityStorage, LibEntity} from '../../entity/libraries/LibEntity.sol';
import {LibAccess} from '../../core/LibAccess.sol';
import {LibRoles} from '../../core/LibRoles.sol';
import {RegistrationTerms} from '../../registry/extensions/registration/interfaces/IRegistration.sol';
import {LibTermsOwner} from '../../entity/libraries/LibTermsOwner.sol';

struct RegistrarConstructorArgs {
   address owner; //can be zero
    address[] otherAdmins; //can be empty
    address extensionManager;
    address factory;
    address registrar;
    //address worldRegistry

}

contract Registrar is CoreShell, IRegistrar {

    address public immutable factory;
    address public immutable registry;

    constructor(RegistrarConstructorArgs memory args) CoreShell(CoreShellConstructorArgs({
        owner: args.owner,
        otherAdmins: args.otherAdmins,
        extensionManager: args.extensionManager
    })) { 
        require(args.factory != address(0), "Factory cannot be zero address");
        require(args.registrar != address(0), "Registrar cannot be zero address");
        //require(args.worldRegistry != address(0), "WorldRegistry cannot be zero address");
        factory = args.factory;
        registry = args.registrar;
    }

    function encodeInitData(RegistrationTerms calldata terms) public pure returns (bytes memory) {
        return abi.encode(terms);
    }

    function init(address owner, string calldata name, bytes calldata initData) external override {
        EntityStorage storage es = LibEntity.load();
        es.active = true;
        es.name = name;
        LibAccess._setOwner(owner);
        LibAccess._grantRevokableRole(LibRoles.ROLE_SIGNER, owner);
        RegistrationTerms memory terms = abi.decode(initData, (RegistrationTerms));
        require(terms.gracePeriodDays > 0, "Registrar: grace period must be greater than 0 regardless of terms coverage");
        LibTermsOwner.load().terms = terms;
    }

    /**
     * @dev Check if the given address is the registry holding the registered entity in which
     * this extension is installed.
     */
    function isYourRegistry(address r) public view returns (bool) {
        return registry == r;
    }

    function isYourFactory(address f) public view returns (bool) {
        return factory == f;
    }


    function isSigner(address a) external view returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_SIGNER, a);
    }

}
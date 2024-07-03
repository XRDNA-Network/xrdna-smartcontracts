// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {LibStorageSlots} from '../../core-libs/LibStorageSlots.sol';
import {LibAccess} from '../../core-libs/LibAccess.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../entity-libs/removal/LibRemovableEntity.sol';
import {NewWorldArgs} from '../interfaces/IRegistrar.sol';
import {IWorldRegistry, CreateWorldArgs} from '../../world/interfaces/IWorldRegistry.sol';
import {LibTermsOwner} from '../../core-libs/LibTermsOwner.sol';
import {CommonInitArgs} from '../../entity-libs/interfaces/IRegisteredEntity.sol';

library LibRegistrar {

    function init(CommonInitArgs memory args) external {
        require(args.owner != address(0), "LibRegistrar: owner cannot be zero address");
        require(bytes(args.name).length > 0, "LibRegistrar: name cannot be empty");
        require(args.termsOwner != address(0), "LibRegistrar: terms owner cannot be zero address");
        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
        rs.termsOwner = args.termsOwner;
    }

    function registerWorld(IWorldRegistry worldRegistry, NewWorldArgs memory args) external returns (address world)  {
       
        CreateWorldArgs memory createArgs = CreateWorldArgs({
            owner: args.owner,
            baseVector: args.baseVector,
            name: args.name,
            terms: args.terms,
            expiration: args.expiration,
            ownerTermsSignature: args.ownerTermsSignature,
            vectorAuthoritySignature: args.vectorAuthoritySignature,
            initData: args.initData
        });
        address a = worldRegistry.createWorld(createArgs);
        require(a != address(0), "Registrar: world registry returned zero address");
        return a;
    }
}
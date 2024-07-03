// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress, LibVectorAddress} from "../../core-libs/LibVectorAddress.sol";
import {LibAccess} from "../../core-libs/LibAccess.sol";
import {LibTermsOwner, TermsStorage} from "../../core-libs/LibTermsOwner.sol";
import {LibRemovableEntity, RemovableEntityStorage} from '../../entity-libs/removal/LibRemovableEntity.sol';
import {RegistrationTerms} from "../../core-libs/LibTypes.sol";
import {CommonInitArgs} from "../../entity-libs/interfaces/IRegisteredEntity.sol";


library LibWorld {


    using LibVectorAddress for VectorAddress;

    function initWorld(CommonInitArgs memory args) external {
        require(args.owner != address(0), "World: owner is the zero address");
        require(bytes(args.name).length > 0, "World: name is empty");
        require(args.termsOwner != address(0), "World: terms owner is the zero address");
        args.vector.validate(false, false);
        RegistrationTerms memory cTerms = abi.decode(args.initData, (RegistrationTerms));
        require(cTerms.gracePeriodDays > 0, "World: grace period for world must be more than 0");
        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
        rs.vector = args.vector;
        rs.termsOwner = args.termsOwner;
    }
}
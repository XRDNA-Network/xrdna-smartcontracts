// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibRegistration} from "../../libraries/common/LibRegistration.sol";
import {RegistrarInitArgs} from "../../interfaces/registrar/IRegistrarInit.sol";

library LibWorldRegistration {
    bytes32 constant WORLD_TERMS = keccak256("WORLD_TERMS");

    function init(RegistrarInitArgs calldata args) external {
        LibRegistration.setTerms(WORLD_TERMS, args.worldRegistrationTerms);
    }
}
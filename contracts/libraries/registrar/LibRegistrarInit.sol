// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from "../../libraries/common/LibRegistration.sol";
import {RegistrarInitArgs} from "../../interfaces/registrar/IRegistrarInit.sol";
import {LibSigners} from "../../libraries/common/LibSigners.sol";
import {LibRegistrarBasicInfo} from "./LibRegistrarBasicInfo.sol";
import {LibWorldRegistration} from "./LibWorldRegistration.sol";
import {LibFunds} from "../common/LibFunds.sol";
import "hardhat/console.sol";

library LibRegistrarInit {

    function init(RegistrarInitArgs calldata args) external {
        console.log("LibRegistrarInit: init being called");
       // LibRegistrarBasicInfo.init(args);
        //LibWorldRegistration.init(args);
        //address[] memory signers = new address[](1);
        //signers[0] = args.owner;
        //LibSigners.addSigners(signers);
    }

    function simpleInit(address owner) external {
        console.log("LibRegistrarInit: simple being called");
        LibFunds.setOwner(owner);
    }
}
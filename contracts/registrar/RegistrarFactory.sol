// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrarInitArgs, IRegistrarInit} from "../interfaces/registrar/IRegistrarInit.sol";
import "hardhat/console.sol";

contract RegistrarFactory {

    function initRegistrar(RegistrarInitArgs calldata args, IRegistrarInit registrar) external {
        registrar.init(args);
    }
}
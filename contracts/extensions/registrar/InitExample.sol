// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ISupportsMixins} from "../../interfaces/ISupportsMixins.sol";
import {RegistrarInitArgs, IRegistrarInit} from "../../interfaces/registrar/IRegistrarInit.sol";
import {LibSigners} from "../../libraries/common/LibSigners.sol";
import {LibFunds} from "../../libraries/common/LibFunds.sol";
import "hardhat/console.sol";

contract InitExample is ISupportsMixins, IRegistrarInit {

    address immutable public registrarFactory;

    modifier onlyFactory() {
        require(msg.sender == registrarFactory, "InitExample: Only factory can call");
        _;
    }

    constructor(address regFactory) {
        require(regFactory != address(0), "InitExample: Invalid registrar factory");
        registrarFactory = regFactory;
    }


    function init(RegistrarInitArgs calldata args) external override onlyFactory {
        console.log("InitExample: init being called");
        address[] memory signers = new address[](1);
        signers[0] = args.owner;
        LibSigners.addSigners(signers);
        LibFunds.setOwner(args.owner);
    }

    function mixins() external view override returns (bytes4[] memory) {
        bytes4[] memory _mixins = new bytes4[](1);
        _mixins[0] = this.init.selector;
        return _mixins;
    }
}
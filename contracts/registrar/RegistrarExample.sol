// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Mixin} from "../Mixin.sol";
import {ISupportsSigners} from "../interfaces/common/ISupportsSigners.sol";
import {ISupportsHook} from "../interfaces/common/ISupportsHook.sol";
import {ISupportsFunds} from "../interfaces/common/ISupportsFunds.sol";
import {ISupportsOwner} from "../interfaces/common/ISupportsOwner.sol";
import {IRegistrarInit} from "../interfaces/registrar/IRegistrarInit.sol"; 


import {LibSigners} from "../libraries/common/LibSigners.sol";
import {LibHook} from "../libraries/common/LibHook.sol";
import {FundsStorage, LibFunds} from "../libraries/common/LibFunds.sol";
import {LibRegistrarInit, RegistrarInitArgs} from "../libraries/registrar/LibRegistrarInit.sol";
import "hardhat/console.sol";

contract RegistrarExample is Mixin {

    bytes4 constant IS_SIGNER = ISupportsSigners.isSigner.selector;
    address factory;

    constructor(address signer, address _factory) {
        factory = _factory;
        _supportSigners();
        _supportHook();
        _supportFunds(signer);
        _supportInit();
        
        address[] memory signers = new address[](1);
        signers[0] = signer;
        LibSigners.addSigners(signers);
    }

    function onlyFactory(address a) internal view returns (bool) {
        require(a == factory, "Registrar: only factory");
        return true;
    }

    function onlySigner(address a) internal view returns (bool)  {
        require(LibSigners.isSigner(a), "Registrar: only signer");
        return true;
    }

    receive() external payable {}

    fallback() external payable {
        bytes4 selector = msg.sig;
        console.log("Fallback Selector");
        console.logBytes4(selector);
        console.log("Fallback Data");
        console.logBytes(msg.data);
        bytes memory result = callFn(selector, msg.data);
        assembly {
            return(add(result, 0x20), mload(result))
        }
    }   

    function _supportSigners() internal {
        address libSig = address(LibSigners);
        _addMixin(ISupportsSigners.isSigner.selector, libSig);
        _addMixin(ISupportsSigners.addSigners.selector, libSig, onlySigner);
        _addMixin(ISupportsSigners.removeSigners.selector, libSig, onlySigner);
    }

    function _supportHook() internal {
        address libHook = address(LibHook);

        _addMixin(ISupportsHook.getHook.selector, libHook);
        _addMixin(ISupportsHook.setHook.selector, libHook, onlySigner); 
        _addMixin(ISupportsHook.removeHook.selector, libHook, onlySigner);
    }

    function _supportFunds(address owner) internal {
        address libFunds = address(LibFunds);

        _addMixin(ISupportsOwner.owner.selector, libFunds);
        _addMixin(ISupportsFunds.withdraw.selector, libFunds, onlySigner);

        FundsStorage storage fs = LibFunds.load();
        fs.owner = owner;
    }

    /*
    function init(RegistrarInitArgs calldata args) external {
        require(onlySigner(msg.sender), "Registrar: only signer");
        console.log("init: selelector");
        console.logBytes4(IRegistrarInit.init.selector);
        console.log("init: args");
        console.logBytes(msg.data);

        LibRegistrarInit.init(args);
    }
    */
    
    


    function _supportInit() internal {
        address libInit = address(LibRegistrarInit);
        console.log("Lib's signature");
        console.logBytes4(LibRegistrarInit.init.selector);
        _addMixin(IRegistrarInit.init.selector, libInit, onlySigner);
    }
}
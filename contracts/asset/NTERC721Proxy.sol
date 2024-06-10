// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../BaseProxy.sol';

contract NTERC721Proxy is BaseProxy {

    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}

    function fundsReceived(uint256 amount) internal override {
        //no-op
    }
}
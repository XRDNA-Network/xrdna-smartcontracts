// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxy, BaseProxyConstructorArgs} from '../BaseProxy.sol';
import {ExperienceV1Storage, LibExperienceV1Storage} from '../libraries/LibExperienceV1Storage.sol';

contract ExperienceProxy is BaseProxy {

    constructor(BaseProxyConstructorArgs memory args) BaseProxy(args) {}

    function fundsReceived(uint256 amount) override internal {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        payable(address(s.company)).transfer(amount);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ISupportsMixins} from "../interfaces/ISupportsMixins.sol";
import {Mixin} from "../Mixin.sol";
import "hardhat/console.sol";

contract ExtensionExample is Mixin {


    constructor(ISupportsMixins[] memory mixins) {
        for (uint256 i = 0; i < mixins.length; i++) {
            bytes4[] memory selectors = mixins[i].mixins();
            for (uint256 j = 0; j < selectors.length; j++) {
                _addMixin(selectors[j], address(mixins[i]));
            }
        }
    }

    receive() external payable {}

    fallback() external payable {
        bytes4 selector = msg.sig;
        bytes memory result = callFn(selector, msg.data);
        assembly {
            return(add(result, 0x20), mload(result))
        }
    }  
}
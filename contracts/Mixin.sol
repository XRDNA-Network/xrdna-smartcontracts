// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {MixinStorage, LibMixin} from "./libraries/common/LibMixin.sol";

abstract contract Mixin {

    using LibMixin for MixinStorage;

    function allowPublic(address a) internal pure returns (bool) {
        return a != address(0);
    }

    function _addMixin(bytes4 _selector, address _implementation) internal {
        LibMixin.load().addMixin(_selector, _implementation, allowPublic);
    }

    function _addMixin(bytes4 _selector, address _implementation, function(address) internal view returns (bool) protection) internal {
        LibMixin.load().addMixin(_selector, _implementation, protection);
    }

    function callFn(bytes4 _selector, bytes calldata data) internal returns (bytes memory) {
        return LibMixin.load().callTarget(_selector, data);
    }
}
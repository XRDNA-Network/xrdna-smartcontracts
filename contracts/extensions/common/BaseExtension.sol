// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {MixinStorage, LibMixin} from "../../libraries/common/LibMixin.sol";

abstract contract BaseExtension{

    using LibMixin for MixinStorage;

    function allowPublic(address a) internal pure returns (bool) {
        return a != address(0);
    }

    function _addFn(bytes4 _selector, address impl) internal {
        LibMixin.load().addMixin(_selector, impl, allowPublic);
    }

    function _addFn(bytes4 _selector, address impl, function (address) internal view returns (bool) protection) internal {
        LibMixin.load().addMixin(_selector, impl, protection);
    }
}
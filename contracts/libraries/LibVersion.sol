// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from './LibTypes.sol';

library LibVersion {

    function equals(Version memory a, Version memory b) internal pure returns (bool) {
        return a.major == b.major && a.minor == b.minor;
    }

    function greaterThan(Version memory a, Version memory b) internal pure returns (bool) {
        if (a.major > b.major) {
            return true;
        } else if (a.major == b.major) {
            return a.minor > b.minor;
        }
        return false;
    }

    function lessThan(Version memory a, Version memory b) internal pure returns (bool) {
        if (a.major < b.major) {
            return true;
        } else if (a.major == b.major) {
            return a.minor < b.minor;
        }
        return false;
    }
}
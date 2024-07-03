// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ILoopback} from './ILoopback.sol';

library LibDelegation {

    function sCall(address tgt, bytes memory data) external view returns (bytes memory) {
        bytes memory callData = abi.encodeWithSelector(ILoopback.staticLoop.selector, tgt, data);
        (bool success, bytes memory returnData) = address(this).staticcall(callData);
        if (success) {
            return returnData;
        } else {
            // If there is a revert reason string, return it as a string
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
    }

    function dCall(address tgt, bytes memory data) external returns (bytes memory) {
        return _doCall(tgt, data);
    }

    function _doCall(address impl, bytes memory data) private returns (bytes memory) {
        (bool success, bytes memory returnData) = impl.delegatecall(data);
        if (success) {
            return returnData;
        } else {
            // If there is a revert reason string, return it as a string
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert("Function call reverted");
            }
        }
    }
}
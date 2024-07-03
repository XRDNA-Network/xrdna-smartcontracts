// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {ISignersSupport} from './ISignersSupport.sol';

interface ISignersExtension is ISignersSupport {
    function isSigner(address _signer) external view returns (bool);

    function addSigners(address[] calldata _signers) external;

    function removeSigners(address[] calldata _signers) external;
}
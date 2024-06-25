// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import { IBasicEntitySupport } from "./IBasicEntitySupport.sol";
import { IRegisteredEntity } from "../../../interfaces/IRegisteredEntity.sol";

interface IBasicEntityExt is IRegisteredEntity, IBasicEntitySupport {

    function isSigner(address a) external view override(IRegisteredEntity, IBasicEntitySupport) returns (bool);
    function init(address owner, string calldata name, bytes calldata initData) external override(IRegisteredEntity, IBasicEntitySupport);
}
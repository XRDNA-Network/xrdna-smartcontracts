// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {Version} from '../../libraries/LibTypes.sol';

struct CommonInitArgs {
    address owner;
    address termsOwner;
    address registry;
    string name;
    VectorAddress vector;
    bytes initData;
}

interface IRegisteredEntity {

    function name() external view returns (string memory);
    function init(CommonInitArgs memory args) external;
    function version() external view returns (Version memory);
}
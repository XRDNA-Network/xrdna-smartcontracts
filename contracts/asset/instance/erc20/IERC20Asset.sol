// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IMintableAsset} from '../../IMintableAsset.sol';

interface IERC20Asset is IMintableAsset {


    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    

}
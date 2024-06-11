// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IBasicAsset} from './IBasicAsset.sol';

interface IMintableAsset is IBasicAsset {

    
    function canMint(address to, bytes calldata data) external view returns (bool);
    function mint(address to, bytes calldata data) external;
    function revoke(address holder, bytes calldata data) external;
    
}
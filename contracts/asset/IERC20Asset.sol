// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IERC20Asset is IERC20 {
    function mint(address to, uint256 amt) external;
    function revoke(address tgt, uint256 amt) external;
}
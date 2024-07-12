// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatar} from '../avatar/instance/IAvatar.sol';

interface IAvatarV2 is IAvatar {

    function setValue(uint256 _value) external;

    function getValue() external view returns (uint256);

}
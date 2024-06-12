// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {CompanyRegistrationArgs} from './IWorldV2.sol';
import {AvatarRegistrationRequest} from '../../avatar/IAvatarRegistry.sol';

interface IWorldHook {

    function beforeRegisterCompany(CompanyRegistrationArgs memory args) external returns (bool);
    function beforeRegisterAvatar(AvatarRegistrationRequest memory req) external returns (bool);
}
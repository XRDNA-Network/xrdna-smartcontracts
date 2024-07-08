// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IRegistration} from '../../interfaces/registry/IRegistration.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';


struct AvatarInitArgs {
    bool canReceiveTokensOutsideExperience;
    address defaultExperience;
    bytes appearanceDetails;
}

struct CreateAvatarArgs {
    bool sendTokensToOwner;
    address owner;
    string name;
    bytes initData; //encoded initArgs above
}

interface IAvatarRegistry is IRegistration, IRegistryFactory, IAccessControl {
    function worldRegistry() external view returns (address);
    function createAvatar(CreateAvatarArgs calldata args) external payable returns (address);
}
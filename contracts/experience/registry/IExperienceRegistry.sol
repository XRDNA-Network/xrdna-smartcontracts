// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {IRemovableRegistry} from '../../interfaces/registry/IRemovableRegistry.sol';
import {IVectoredRegistry} from '../../interfaces/registry/IVectoredRegistry.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';

struct CreateExperienceArgs {
    address company;
    string name;
    VectorAddress vector;
    uint256 entryFee;
    bytes initData;
}

interface IExperienceRegistry is IRemovableRegistry, IVectoredRegistry {

    function createExperience(CreateExperienceArgs calldata args) external payable returns (address, uint256);
}
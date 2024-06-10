// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {IExperienceHook} from './IExperienceHook.sol';
import {IPortalCondition} from '../portal/IPortalCondition.sol';

struct JumpEntryRequest {
    address sourceWorld;
    address sourceCompany;
    address avatar;
}

interface IExperience {
    event JumpEntry(address indexed sourceWorld, address indexed sourceCompany, address indexed avatar, uint256 attachedFees);
    event HookAdded(address indexed hook);
    event HookRemoved(address indexed hook);
    event ExperienceUpgraded(address indexed oldVersion, address indexed newVersion);
    event PortalFeeChanged(uint256 newFee);
    
    function company() external view returns (address);
    function world() external view returns (address);
    function vectorAddress() external view returns (VectorAddress memory);
    function name() external view returns (string memory);
    function entryFee() external view returns (uint256);
    function addHook(IExperienceHook hook) external;
    function removeHook() external;
    function addPortalCondition(IPortalCondition condition) external;
    function removePortalCondition() external;
    function changePortalFee(uint256 fee) external;

    function connectionDetails() external view returns (bytes memory);
    function entering(JumpEntryRequest memory request) external payable returns (bytes memory);
    function init(address company, string memory _name, VectorAddress memory vector, bytes memory initData) external;
    function upgrade(bytes memory initData) external;
    function experienceUpgraded(address nextVersion) external;
}
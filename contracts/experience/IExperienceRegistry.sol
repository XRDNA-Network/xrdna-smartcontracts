// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {IExperience} from './IExperience.sol';
import {ICompanyRegistry} from '../company/ICompanyRegistry.sol';
import {IPortalRegistry} from '../portal/IPortalRegistry.sol';

struct RegisterExperienceRequest {
    VectorAddress vector;
    bytes initData;
    string name;
}

struct ExperienceInfo {
    address company;
    address world;
    IExperience experience;
    uint256 portalId;
}

interface IExperienceRegistry {
    
    event ExperienceRegistered(address indexed world, address indexed company, address indexed experience, string name);
    function getExperienceByVector(VectorAddress memory vector) external view returns (ExperienceInfo memory);
    function setExperienceFactory(address factory) external;
    function setCompanyRegistry(ICompanyRegistry reg) external;
    function setPortalRegistry(IPortalRegistry reg) external;
    function isExperience(address exp) external view returns (bool);
    function registerExperience(RegisterExperienceRequest memory request) external returns (address, uint256);
    function upgradeExperience(bytes calldata initData) external;
    function currentExperienceVersion() external view returns (uint256);
}
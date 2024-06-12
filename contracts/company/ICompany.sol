// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {ICompanyHook} from './ICompanyHook.sol';
import {IAssetHook} from '../asset/IAssetHook.sol';
import {IBaseAccess} from '../IBaseAccess.sol';

struct AddExperienceArgs {
    string name;
    bytes initData;
}

struct DelegatedAvatarJumpRequest {
    address avatar;
    uint256 portalId;
    uint256 agreedFee;
    bytes avatarOwnerSignature;
}

struct CompanyInitArgs {
     //the address of the company owner
    address owner;

     //the world in which the company operates
    address world;

    //the vector address of the company
    VectorAddress vector;

    //initialization data to pass to the company contract
    bytes initData;

    //the name of the company, must be globally unique, case-insensitive
    string name;
}

interface ICompany is IBaseAccess {

    event ExperienceAdded(address indexed experience, uint256 portalId);
    event CompanyUpgraded(address indexed oldVersion, address indexed nextVersion);
    event CompanyHookSet(address indexed hook);
    event CompanyHookRemoved();
    event AssetMinted(address indexed asset, address indexed to, uint256 amountOrTokenId);
    event AssetRevoked(address indexed asset, address indexed holder, uint256 amountOrTokenId);

    function version() external view returns (uint256);
    function owner() external view returns (address);
    function name() external view returns (string memory);
    function world() external view returns (address);
    function vectorAddress() external view returns (VectorAddress memory);
    function canMint(address asset, address to, bytes calldata data) external view returns (bool);
    
    function init(CompanyInitArgs memory args) external;
    function addExperience(AddExperienceArgs memory args) external;
    function mint(address asset, address to, bytes calldata data) external;
    function revoke(address asset, address holder, bytes calldata data) external;
    function upgrade(bytes memory initData) external;
    function upgradeComplete(address nextVersion) external;
    function withdraw(uint256 amount) external;
    function setHook(ICompanyHook hook) external;
    function removeHook() external;

    function addExperienceCondition(address experience, address condition) external;
    function removeExperienceCondition(address experience) external;

    function addAssetCondition(address asset, address condition) external;
    function removeAssetCondition(address asset) external;

    function addAssetHook(address asset, IAssetHook hook) external;
    function removeAssetHook(address asset) external;

    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) external;
    
}
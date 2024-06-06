// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../VectorAddress.sol';
import {AssetType} from '../asset/AssetFactory.sol';
import {ICompanyHook} from './ICompanyHook.sol';

struct AddExperienceArgs {
    string name;
    bytes initData;
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

interface ICompany {

    event ExperienceAdded(address indexed experience, uint256 portalId);
    event CompanyUpgraded(address indexed oldVersion, address indexed nextVersion);
    event CompanyHookSet(address indexed hook);
    event CompanyHookRemoved();
    event SignerAdded(address indexed signer);
    event SignerRemoved(address indexed signer);
    event AssetMinted(address indexed asset, address indexed to, uint256 amountOrTokenId);
    event AssetRevoked(address indexed asset, address indexed holder, uint256 amountOrTokenId);

    function owner() external view returns (address);
    function name() external view returns (string memory);
    function world() external view returns (address);
    function vectorAddress() external view returns (VectorAddress memory);
    function isSigner(address signer) external view returns (bool);
    function canMint(address asset, address to, uint256 amount) external view returns (bool);
    function upgraded() external view returns (bool);
    
    function init(CompanyInitArgs memory args) external;
    function addSigner(address signer) external;
    function removeSigner(address signer) external;
    function addExperience(AddExperienceArgs memory args) external;
    function mint(address asset, address to, uint256 amount) external;
    function revoke(address asset, address holder, uint256 amountOrTokenId) external;
    function upgrade(bytes memory initData) external;
    function upgradeComplete(address nextVersion) external;
    function withdraw(uint256 amount) external;
    function setHook(ICompanyHook hook) external;
    function removeHook() external;
    
}
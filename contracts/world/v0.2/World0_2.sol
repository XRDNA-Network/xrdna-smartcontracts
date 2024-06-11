// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorld0_2, CompanyRegistrationArgs} from './IWorld0_2.sol';
import {VectorAddress} from '../../VectorAddress.sol';
import {IAvatarRegistry, AvatarRegistrationRequest} from '../../avatar/IAvatarRegistry.sol';
import {WorldCreateRequest} from './IWorldFactory0_2.sol';
import {ICompanyRegistry, CompanyRegistrationRequest} from '../../company/ICompanyRegistry.sol';
import {IWorldRegistry0_2} from './IWorldRegistry0_2.sol';
import {LibStringCase} from '../../LibStringCase.sol';
import {IWorld} from '../v0.1/IWorld.sol';
import {IWorldHook} from './IWorldHook.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {BaseProxyStorage, LibProxyAccess, LibBaseProxy} from '../../libraries/LibBaseProxy.sol';
import {WorldV2Storage, LibWorldV2Storage} from '../../libraries/LibWorldV2Storage.sol';
import {BaseAccess} from '../../BaseAccess.sol';

struct WorldConstructorArgs {
    address worldFactory;
    address worldRegistry;
    address companyRegistry;
    address avatarRegistry;
}

contract World0_2 is IWorld0_2, BaseAccess, ReentrancyGuard {
    using LibStringCase for string;
    using LibProxyAccess for BaseProxyStorage;

    uint256 public constant override version = 2;
    
    //Fields populated at master copy deploy time
    IWorldRegistry0_2 public immutable worldRegistry;
    address public immutable worldFactory;
    ICompanyRegistry public immutable companyRegistry;
    IAvatarRegistry public immutable avatarRegistry;

    modifier onlyFactory {
        require(worldFactory != address(0), "World0_2: worldFactory not set");
        require(msg.sender == worldFactory, "World0_2: caller is not factory");
        _;
    }

    modifier onlyRegistry {
        require(address(worldRegistry) != address(0), "World0_2: worldRegistry not set");
        require(msg.sender == address(worldRegistry), "World0_2: caller is not registry");
        _;
    }

    constructor(WorldConstructorArgs memory args) {
        require(args.worldFactory != address(0), "World0_2: worldFactory cannot be zero address");
        require(args.worldRegistry != address(0), "World0_2: worldRegistry cannot be zero address");
        require(args.companyRegistry != address(0), "World0_2: companyRegistry cannot be zero address");
        require(args.avatarRegistry != address(0), "World0_2: avatarRegistry cannot be zero address");
        worldRegistry = IWorldRegistry0_2(args.worldRegistry);
        worldFactory = args.worldFactory;
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
    }

    receive() external payable {
        emit ReceivedFunds(msg.sender, msg.value);
    }

    function init(WorldCreateRequest memory request) external onlyFactory {
        BaseProxyStorage storage bs = LibBaseProxy.load();

        require(request.owner != address(0), "World0_2: owner cannot be zero address");
        require(bytes(request.baseVector.x).length != 0, "World0_2: baseVector.x cannot be zero");
        require(bytes(request.baseVector.y).length != 0, "World0_2: baseVector.y cannot be zero");
        require(bytes(request.baseVector.z).length != 0, "World0_2: baseVector.z cannot be zero");
        require(request.baseVector.p == 0, "World0_2: baseVector.p must be zero");
        require(request.baseVector.p_sub == 0, "World0_2: baseVector.p_sub must be zero");
        require(bytes(request.name).length > 0, "World0_2: name cannot be empty");
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        ws.owner = request.owner;
        ws.baseVector = request.baseVector;
        ws.name = request.name;
        ws.nextP = 0;
        ws.oldVersion = request.oldWorld;
        bs.grantRole(LibProxyAccess.ADMIN_ROLE, ws.owner);
        bs.grantRole(LibProxyAccess.SIGNER_ROLE, ws.owner);
    }

    function getOwner() external view returns (address) {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        return ws.owner;
    }

    function getBaseVector() external view returns (VectorAddress memory) {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        return ws.baseVector;
    }

    function getName() external view returns (string memory) {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        return ws.name;
    }

    function registerCompany(CompanyRegistrationArgs memory args) public payable onlySigner nonReentrant returns (address company) {
        require(args.owner != address(0), "World0_2: company owner cannot be zero address");
        require(bytes(args.name).length > 0, "World0_2: company name cannot be empty");
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        if(address(ws.hook) != address(0)) {
            require(ws.hook.beforeRegisterCompany(args), "World0_2: hook rejected company registration");
        }

        ++ws.nextP;
        VectorAddress memory vector = VectorAddress({
            x: ws.baseVector.x,
            y: ws.baseVector.y,
            z: ws.baseVector.z,
            t: ws.baseVector.t,
            p: ws.nextP,
            p_sub: 0
        });
        company = companyRegistry.registerCompany{value: msg.value}(CompanyRegistrationRequest({
            owner: args.owner,
            vector: vector,
            name: args.name,
            initData: args.initData,
            sendTokensToCompanyOwner: args.sendTokensToCompanyOwner
        }));
        
        emit CompanyRegistered(company, vector, args.name);
    }

    function registerAvatar(AvatarRegistrationRequest memory args) external payable onlySigner nonReentrant returns (address avatar) {
        require(args.avatarOwner != address(0), "World0_2: avatar owner cannot be zero address");
        require(bytes(args.username).length > 0, "World0_2: avatar username cannot be empty");
        
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        if(address(ws.hook) != address(0)) {
            require(ws.hook.beforeRegisterAvatar(args), "World0_2: hook rejected avatar registration");
        }

        avatar = avatarRegistry.registerAvatar{value: msg.value}(AvatarRegistrationRequest({
            avatarOwner: args.avatarOwner,
            username: args.username,
            defaultExperience: args.defaultExperience,
            initData: args.initData,
            sendTokensToAvatarOwner: args.sendTokensToAvatarOwner
        }));
        emit AvatarRegistered(avatar, args.defaultExperience);
    }


    function upgrade(bytes calldata initData) public onlyAdmin {
        worldRegistry.worldUpgradeSelf(initData);
    }

    function upgradeComplete(address nextVersion) public onlyFactory {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        address old = bs.implementation;
        bs.implementation = nextVersion;
        emit WorldUpgraded(old, nextVersion);
    }

    function setHook(IWorldHook _hook) external onlyAdmin {
        require(address(_hook) != address(0), "World0_2: hook cannot be zero address");
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        ws.hook = _hook;
        emit WorldHookSet(address(_hook));
    }

    function removeHook() external onlyAdmin {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        ws.hook = IWorldHook(address(0));
        emit WorldHookRemoved();
    }

    function withdraw(uint256 amount) external onlyAdmin {
        require(amount <= address(this).balance, "World0_2: amount exceeds balance");
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        payable(ws.owner).transfer(amount);
    }
    
}
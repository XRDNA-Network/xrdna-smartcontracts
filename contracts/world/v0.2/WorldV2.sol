// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorldV2, CompanyRegistrationArgs} from './IWorldV2.sol';
import {VectorAddress} from '../../VectorAddress.sol';
import {IAvatarRegistry, AvatarRegistrationRequest} from '../../avatar/IAvatarRegistry.sol';
import {WorldCreateRequest} from './IWorldFactoryV2.sol';
import {ICompanyRegistry, CompanyRegistrationRequest} from '../../company/ICompanyRegistry.sol';
import {IWorldRegistryV2} from './IWorldRegistryV2.sol';
import {LibStringCase} from '../../LibStringCase.sol';
import {IWorld} from '../v0.1/IWorld.sol';
import {IWorldHook} from './IWorldHook.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {BaseProxyStorage, LibProxyAccess, LibBaseProxy} from '../../libraries/LibBaseProxy.sol';
import {WorldV2Storage, LibWorldV2Storage} from '../../libraries/LibWorldV2Storage.sol';
import {BaseAccess} from '../../BaseAccess.sol';
import {RegisterExperienceRequest} from '../../experience/IExperienceRegistry.sol';
import {IExperienceRegistry} from '../../experience/IExperienceRegistry.sol';
import {ICompany} from '../../company/ICompany.sol';

//master world copy constructor args
struct WorldConstructorArgs {
    address worldFactory;
    address worldRegistry;
    address companyRegistry;
    address avatarRegistry;
    address experienceRegistry;
}

/**
 * @dev World contract version 2. This contract is responsible for registering and
 * managing companies and avatars within a world. There was an early version "1" but it 
 * was just for prototype purposes.
 */
contract WorldV2 is IWorldV2, BaseAccess, ReentrancyGuard {
    using LibStringCase for string;
    using LibProxyAccess for BaseProxyStorage;

    uint256 public constant override version = 2;
    
    //Fields populated at master copy deploy time
    IWorldRegistryV2 public immutable worldRegistry;
    address public immutable worldFactory;
    ICompanyRegistry public immutable companyRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;

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

    modifier onlyCompany {
        require(address(companyRegistry) != address(0), "World0_2: companyRegistry not set");
        require(companyRegistry.isRegisteredCompany(msg.sender), "World0_2: caller is not company");
        _;
    }

    constructor(WorldConstructorArgs memory args) {
        require(args.worldFactory != address(0), "World0_2: worldFactory cannot be zero address");
        require(args.worldRegistry != address(0), "World0_2: worldRegistry cannot be zero address");
        require(args.companyRegistry != address(0), "World0_2: companyRegistry cannot be zero address");
        require(args.avatarRegistry != address(0), "World0_2: avatarRegistry cannot be zero address");
        require(args.experienceRegistry != address(0), "World0_2: experienceRegistry cannot be zero address");
        worldRegistry = IWorldRegistryV2(args.worldRegistry);
        worldFactory = args.worldFactory;
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }

    receive() external payable {
        emit ReceivedFunds(msg.sender, msg.value);
    }

    /**
     * @inheritdoc IWorldV2
     */
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

    /**
        * @inheritdoc IWorldV2
     */
    function getOwner() external view returns (address) {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        return ws.owner;
    }

    /**
        * @inheritdoc IWorldV2
     */
    function getBaseVector() external view returns (VectorAddress memory) {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        return ws.baseVector;
    }

    /**
        * @inheritdoc IWorldV2
     */
    function getName() external view returns (string memory) {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        return ws.name;
    }

    /**
        * @inheritdoc IWorldV2
     */
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
            p: ws.nextP, //increment for each new company
            p_sub: 0 //experience offset set to zero for new companies within a world
        });
        company = companyRegistry.registerCompany{value: msg.value}(CompanyRegistrationRequest({
            owner: args.owner,
            vector: vector,
            name: args.name,
            initData: args.initData,
            sendTokensToCompanyOwner: args.sendTokensToCompanyOwner
        }));
        
        emit WorldRegisteredCompany(company, vector, args.name);
    }

    /**
        * @inheritdoc IWorldV2
     */
    function removeCompany(address company) public onlyAdmin nonReentrant {
        ICompany c = ICompany(company);
        require(c.world() == address(this), "World0_2: company world does not match this world contract");
        companyRegistry.removeCompany(company);
        emit WorldRemovedCompany(company);
    }

    /**
        * @inheritdoc IWorldV2
     */
    function registerExperience(RegisterExperienceRequest memory req) public onlyCompany nonReentrant returns (address experience, uint256) {
        require(req.company == msg.sender, "World0_2: caller does not match company in request");
        require(ICompany(msg.sender).world() == address(this), "World0_2: company world does not match this world contract");
        require(req.vector.p_sub > 0, "World0_2: p_sub must not be zero for experience registration");
        (address exp, uint256 portalId) = experienceRegistry.registerExperience(req);
        emit WorldAddedExperience(exp, req.company, portalId);
        return (exp, portalId);
    }
    
    /**
        * @inheritdoc IWorldV2
     */
    function deactivateExperience(address experience) public onlyCompany nonReentrant returns (uint256) {
        require(ICompany(msg.sender).world() == address(this), "World0_2: company world does not match this world contract");
        return experienceRegistry.removeExperience(msg.sender, experience);
    }

    /**
        * @inheritdoc IWorldV2
     */
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
        emit WorldRegisteredAvatar(avatar, args.defaultExperience);
    }

    /**
        * @inheritdoc IWorldV2
     */
    function upgrade(bytes calldata initData) public onlyAdmin {
        worldRegistry.upgradeWorld(initData);
    }

    /**
        * @inheritdoc IWorldV2
     */
    function upgradeComplete(address nextVersion) public onlyFactory {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        address old = bs.implementation;
        bs.implementation = nextVersion;
        emit WorldUpgraded(old, nextVersion);
    }

    /**
        * @inheritdoc IWorldV2
     */
    function setHook(IWorldHook _hook) external onlyAdmin {
        require(address(_hook) != address(0), "World0_2: hook cannot be zero address");
        require(address(_hook).code.length > 0, "World0_2: hook address is not a contract");
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        ws.hook = _hook;
        emit WorldHookSet(address(_hook));
    }

    /**
        * @inheritdoc IWorldV2
     */
    function removeHook() external onlyAdmin {
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        ws.hook = IWorldHook(address(0));
        emit WorldHookRemoved();
    }

    /**
        * @inheritdoc IWorldV2
     */
     function hook() external view returns (IWorldHook) {
         WorldV2Storage storage ws = LibWorldV2Storage.load();
         return ws.hook;
     }

    /**
        * @inheritdoc IWorldV2
     */
    function withdraw(uint256 amount) external onlyAdmin {
        require(amount <= address(this).balance, "World0_2: amount exceeds balance");
        WorldV2Storage storage ws = LibWorldV2Storage.load();
        payable(ws.owner).transfer(amount);
    }
    
}
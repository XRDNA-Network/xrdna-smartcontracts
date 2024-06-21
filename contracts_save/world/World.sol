// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorld, AvatarRegistrationArgs, CompanyRegistrationArgs} from './IWorld.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IAvatarRegistry, AvatarRegistrationRequest} from '../avatar/IAvatarRegistry.sol';
import {ICompanyRegistry, CompanyRegistrationRequest} from '../company/ICompanyRegistry.sol';
import {IWorldRegistry, WorldRegistrationRequest} from './IWorldRegistry.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IWorldHook} from './IWorldHook.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {BaseProxyStorage, LibProxyAccess, LibBaseProxy} from '../libraries/LibBaseProxy.sol';
import {WorldV1Storage, LibWorldV1Storage} from '../libraries/LibWorldV1Storage.sol';
import {BaseAccess} from '../BaseAccess.sol';
import {RegisterExperienceRequest} from '../experience/IExperienceRegistry.sol';
import {IExperienceRegistry} from '../experience/IExperienceRegistry.sol';
import {ICompany} from '../company/ICompany.sol';
import {HookStorage, LibHooks} from '../libraries/LibHooks.sol';
import {BaseHookSupport} from '../BaseHookSupport.sol';
import {IRegistrar} from '../registrar/IRegistrar.sol';
import {BaseRegistration} from '../BaseRegistration.sol';
import {LibWorld} from './LibWorld.sol';

//master world copy constructor args
struct WorldConstructorArgs {
    address worldFactory;
    address worldRegistry;
    address companyRegistry;
    address avatarRegistry;
    address experienceRegistry;
    address registrarRegistry;
}

/**
 * @dev World contract version 2. This contract is responsible for registering and
 * managing companies and avatars within a world. There was an early version "1" but it 
 * was just for prototype purposes.
 */
contract World is IWorld, BaseAccess, BaseHookSupport, BaseRegistration, ReentrancyGuard {
    using LibStringCase for string;
    using LibProxyAccess for BaseProxyStorage;
    using LibHooks for HookStorage;

    uint256 public constant override version = 1;

    bytes32 public constant TERMS_COMPANY = keccak256("COMPANY_TERMS");
    bytes32 public constant TERMS_AVATAR = keccak256("AVATAR_TERMS");
    
    //Fields populated at master copy deploy time
    IWorldRegistry public immutable worldRegistry;
    address public immutable worldFactory;
    ICompanyRegistry public immutable companyRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    address public immutable registrarRegistry;

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

    modifier onlyActive {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        require(ws.active, "World0_2: world is not active");
        _;
    }

    modifier onlyRegistrarRegistry {
        require(registrarRegistry != address(0), "World0_2: registrarRegistry not set");
        require(msg.sender == registrarRegistry, "World0_2: caller is not registrarRegistry");
        _;
    }

    constructor(WorldConstructorArgs memory args) {
        require(args.worldFactory != address(0), "World0_2: worldFactory cannot be zero address");
        require(args.worldRegistry != address(0), "World0_2: worldRegistry cannot be zero address");
        require(args.companyRegistry != address(0), "World0_2: companyRegistry cannot be zero address");
        require(args.avatarRegistry != address(0), "World0_2: avatarRegistry cannot be zero address");
        require(args.experienceRegistry != address(0), "World0_2: experienceRegistry cannot be zero address");
        require(args.registrarRegistry != address(0), "World0_2: registrarRegistry cannot be zero address");
        worldRegistry = IWorldRegistry(args.worldRegistry);
        worldFactory = args.worldFactory;
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        registrarRegistry = args.registrarRegistry;
    }

    /**
     * @inheritdoc IWorld
     */
    function init(WorldRegistrationRequest memory request) external onlyFactory {
        LibWorld.init(request);
    }

    function isAdmin(address a) internal override(BaseHookSupport,BaseRegistration) view returns (bool) {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        return a == ws.owner;
    }

    function owner() public view override  returns (address) {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        return ws.owner;
    }

    /**
        * @inheritdoc IWorld
     */
    function getBaseVector() external view returns (VectorAddress memory) {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        return ws.baseVector;
    }

    /**
        * @inheritdoc IWorld
     */
    function getName() external view returns (string memory) {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        return ws.name;
    }

    /**
        * @inheritdoc IWorld
     */
    function registrar() external view returns (address) {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        return ws.registrar;
    }

    /**
        * @inheritdoc IWorld
     */
    function registerCompany(CompanyRegistrationArgs memory args) public payable onlySigner nonReentrant onlyActive returns (address company) {
        (address c, VectorAddress memory vector) = LibWorld.registerCompany(args, companyRegistry);
        require(c != address(0), "World0_2: company registration failed");
        company = c;
        if(msg.value > 0) {
            //transfer funds according to request
            if(args.sendTokensToCompanyOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(company).transfer(msg.value);
            }
        }
        createRegistration(TERMS_COMPANY, company);
        emit WorldRegisteredCompany(company, vector, args.name);
    }

    /**
        * @inheritdoc IWorld
     */
    function deactivateCompany(address company) public onlySigner nonReentrant {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeDeactivateCompany(company), "World0_2: hook rejected company deactivation");
        }
        ICompany c = ICompany(company);
        require(c.world() == address(this), "World0_2: company world does not match this world contract");
        companyRegistry.deactivateCompany(company);
        emit WorldDeactivatedCompany(company);
    }

    /**
        * @inheritdoc IWorld
     */
    function reactivateCompany(address company) public onlySigner onlyActive nonReentrant {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeReactivateCompany(company), "World0_2: hook rejected company reactivation");
        }
        ICompany c = ICompany(company);
        require(c.world() == address(this), "World0_2: company world does not match this world contract");
        companyRegistry.reactivateCompany(company);
        emit WorldReactivatedCompany(company);
    }

    /**
        * @inheritdoc IWorld
     */
    function removeCompany(address company) public override onlySigner nonReentrant {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRemoveCompany(company), "World0_2: hook rejected company removal");
        }
        ICompany c = ICompany(company);
        require(c.world() == address(this), "World0_2: company world does not match this world contract");
        companyRegistry.removeCompany(company);
        removeRegistration(company);
        emit WorldDeactivatedCompany(company);
    }

    /**
        * @inheritdoc IWorld
     */
    function registerExperience(RegisterExperienceRequest memory req) public onlyCompany onlyActive nonReentrant returns (address experience, uint256) {
        require(req.company == msg.sender, "World0_2: caller does not match company in request");
        require(ICompany(msg.sender).world() == address(this), "World0_2: company world does not match this world contract");
        require(req.vector.p_sub > 0, "World0_2: p_sub must not be zero for experience registration");
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRegisterExperience(req), "World0_2: hook rejected experience registration");
        }
        (address exp, uint256 portalId) = experienceRegistry.registerExperience(req);
        emit WorldAddedExperience(exp, req.company, portalId);
        return (exp, portalId);
    }
    
    /**
        * @inheritdoc IWorld
     */
    function deactivateExperience(address experience) public onlyCompany nonReentrant returns (uint256) {
        require(ICompany(msg.sender).world() == address(this), "World0_2: company world does not match this world contract");
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeDeactivateExperience(experience), "World0_2: hook rejected experience deactivation");
        }
        return experienceRegistry.removeExperience(msg.sender, experience);
    }

    /**
        * @inheritdoc IWorld
     */
    function registerAvatar(AvatarRegistrationArgs memory args) external payable onlySigner nonReentrant onlyActive returns (address avatar) {
        require(args.avatarOwner != address(0), "World0_2: avatar owner cannot be zero address");
        require(bytes(args.username).length > 0, "World0_2: avatar username cannot be empty");
        
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRegisterAvatar(args), "World0_2: hook rejected avatar registration");
        }

        avatar = avatarRegistry.registerAvatar(AvatarRegistrationRequest({
            avatarOwner: args.avatarOwner,
            username: args.username,
            defaultExperience: args.defaultExperience,
            initData: args.initData
        }));
        if(msg.value > 0) {
            if (args.sendTokensToAvatarOwner) {
                payable(args.avatarOwner).transfer(msg.value);
            } else {
                payable(avatar).transfer(msg.value);
            }
        }
        createRegistration(TERMS_AVATAR, avatar);
        emit WorldRegisteredAvatar(avatar, args.defaultExperience);
    }

    /**
        * @inheritdoc IWorld
     */
    function upgrade(bytes calldata initData) public onlyAdmin onlyActive {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeUpgrade(initData), "World0_2: hook rejected world upgrade");
        }
        worldRegistry.upgradeWorld(initData);
    }

    /**
        * @inheritdoc IWorld
     */
    function upgradeComplete(address nextVersion) public onlyFactory {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        address old = bs.implementation;
        bs.implementation = nextVersion;
        emit WorldUpgraded(old, nextVersion);
    }

    function deactivate() public override onlyRegistry {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        ws.active = false;
        if(address(this).balance > 0) {
            payable(ws.owner).transfer(address(this).balance);
        }

        emit WorldDeactivated();
    }

    function reactivate() public override onlyRegistry {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        ws.active = true;
        emit WorldReactivated();
    }

    function isActive() public view override returns (bool) {
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        return ws.active;
    }
    
    function renewRegistration() public payable override {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRenewRegistration(), "World0_2: hook rejected world renewal");
        }
       IRegistrar(LibWorldV1Storage.load().registrar).renewWorldRegistration{value: msg.value}(address(this));
    }

    function registrarChanged(address newReg) public override onlyRegistrarRegistry {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRegistrarChanged(this.registrar(), newReg), "World0_2: hook rejected registrar change");
        }
        LibWorldV1Storage.load().registrar = newReg;
        emit WorldRegistrarChanged(newReg);
    }

    function renewAvatarRegistration(address avatar) public payable override {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRenewAvatarRegistration(avatar), "World0_2: hook rejected avatar renewal");
        }
        renewFor(TERMS_AVATAR, avatar);
    }

    function renewCompanyRegistration(address company) public payable override {
        IWorldHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRenewCompanyRegistration(company), "World0_2: hook rejected company renewal");
        }
        renewFor(TERMS_COMPANY, company);
    }

    function _getHook() internal view returns (IWorldHook) {
        return IWorldHook(LibHooks.load().getHook());
    }
}
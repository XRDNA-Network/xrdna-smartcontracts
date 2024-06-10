// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExperience, JumpEntryRequest} from './IExperience.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IBasicCompany} from './IBasicCompany.sol';
import {IExperienceHook} from './IExperienceHook.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IExperienceRegistry} from './IExperienceRegistry.sol';
import {IPortalRegistry} from '../portal/IPortalRegistry.sol';
import {IPortalCondition} from '../portal/IPortalCondition.sol';
import {ExperienceV1Storage, LibExperienceV1Storage} from '../libraries/LibExperienceV1Storage.sol';    
import {BaseProxyStorage, LibBaseProxy, LibProxyAccess} from '../libraries/LibBaseProxy.sol';

struct ExperienceInitData {
    uint256 entryFee;
    bytes connectionDetails;
}

struct ExperienceConstructorArgs {
    address experienceFactory;
    address portalRegistry;
    address experienceRegistry;
}

contract Experience is ReentrancyGuard, IExperience {

    using LibProxyAccess for BaseProxyStorage;

    //initialized when deploying master copy
    address public immutable experienceFactory;
    IPortalRegistry public immutable portalRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    uint256 public constant override version = 1;

    constructor(ExperienceConstructorArgs memory args) {
        require(args.experienceFactory != address(0), "Experience: zero address factory");
        require(args.portalRegistry != address(0), "Experience: zero address portalRegistry");
        require(args.experienceRegistry != address(0), "Experience: zero address experienceRegistry");
        experienceFactory = args.experienceFactory;
        portalRegistry = IPortalRegistry(args.portalRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }

    modifier onlyFactory() {
        require(msg.sender == experienceFactory, "Experience: caller is not the factory");
        _;
    }

    modifier onlyPortalRegistry() {
        require(msg.sender == address(portalRegistry), "Experience: caller is not the portal registry");
        _;
    }

    modifier onlyRegistry {
        require(msg.sender == address(experienceRegistry), "Experience: caller is not the registry");
        _;
    }

    

    modifier onlyCompany() {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        require(msg.sender == address(s.company), "Experience: caller is not the company");
        _;
    }

    modifier notUpgraded {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        require(!s.upgraded, "Experience: cannot use upgraded contract");
        _;
    }

    //all fees go to the company
    receive() external payable {
        
    }

    function encodeInitData(ExperienceInitData memory data) external pure returns (bytes memory) {
        return abi.encode(data);
    }

    function init(address _company, string memory _name, VectorAddress memory vector, bytes memory initData) external onlyFactory override {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        require(address(s.company) == address(0), "Experience: already initialized");
        
        s.company = IBasicCompany(_company);
        ExperienceInitData memory data = abi.decode(initData, (ExperienceInitData));
        s.vectorAddress = vector;
        s.world = s.company.world();
        s.name = _name;
        s.entryFee = data.entryFee;
        s.connectionDetails = data.connectionDetails;
    }

    function world() external view returns (address) {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        return s.world;
    }

    function name() external view returns (string memory) {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        return s.name;
    }

    function entryFee() external view returns (uint256) {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        return s.entryFee;
    }

    function connectionDetails() external view returns (bytes memory) {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        return s.connectionDetails;
    }

    function addHook(IExperienceHook _hook) external override onlyCompany notUpgraded {
        require(address(_hook) != address(0), "Experience: hook zero address");
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        s.hook = _hook;
        emit HookAdded(address(_hook));
    }

    function removeHook() external override onlyCompany notUpgraded {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        require(address(s.hook) != address(0), "Experience: hook not set");
        address a = address(s.hook);
        emit HookRemoved(a);
        delete s.hook;
    }

    function addPortalCondition(IPortalCondition condition) public onlyCompany notUpgraded {
        portalRegistry.addCondition(condition);
    }

    function removePortalCondition() public onlyCompany {
        portalRegistry.removeCondition();
    }

    function changePortalFee(uint256 fee) public onlyCompany {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        s.entryFee = fee;
        portalRegistry.changePortalFee(fee);
        emit PortalFeeChanged(fee);
    }

    function company() external view override returns (address) {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        return address(s.company);
    }

    function vectorAddress() external view override returns (VectorAddress memory) {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        return s.vectorAddress;
    }

    function entering(JumpEntryRequest memory request) external payable override nonReentrant onlyPortalRegistry notUpgraded returns (bytes memory)  {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        if(address(s.hook) != address(0)) {
            bool ok = s.hook.beforeJumpEntry(address(this), request.sourceWorld, request.sourceCompany, request.avatar);
            require(ok, "Experience: hook disallowed entry");
        }
        return s.connectionDetails;
    }

    function upgrade(bytes memory initData) external override onlyCompany notUpgraded {
        ExperienceV1Storage storage s = LibExperienceV1Storage.load();
        s.upgraded = true;
        experienceRegistry.upgradeExperience(initData);
    }

    function experienceUpgraded(address nextVersion) external override onlyRegistry {
        BaseProxyStorage storage ps = LibBaseProxy.load();
        ps.implementation = nextVersion;
        emit ExperienceUpgraded(address(this), nextVersion);
    }
}
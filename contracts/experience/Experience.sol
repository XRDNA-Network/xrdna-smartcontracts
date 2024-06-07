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

struct ExperienceInitData {
    string name;
    uint256 entryFee;
    bytes connectionDetails;
}

struct ExperienceConstructorArgs {
    address experienceFactory;
    address portalRegistry;
    address experienceRegistry;
}

contract Experience is ReentrancyGuard, IExperience {

    //initialized when deploying master copy
    address public immutable experienceFactory;
    IPortalRegistry public immutable portalRegistry;
    IExperienceRegistry public immutable experienceRegistry;

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

    bool public upgraded;
    IBasicCompany public _company;
    address public override world;
    IExperienceHook public hook;
    VectorAddress _vectorAddress;
    string public override name;
    uint256 public override entryFee;
    bytes public override connectionDetails;

    modifier onlyCompany() {
        require(msg.sender == address(_company), "Experience: caller is not the company");
        _;
    }

    modifier onlyExperience() {
        require(msg.sender == address(this), "Experience: caller is not the experience");
        _;
    }

    modifier notUpgraded {
        require(!upgraded, "Experience: cannot use upgraded contract");
        _;
    }

    //all fees go to the company
    receive() external payable {
        payable(address(_company)).transfer(msg.value);
    }

    function init(address __company,VectorAddress memory vector, bytes memory initData) external onlyFactory override {
        require(address(__company) == address(0), "Experience: already initialized");
        _company = IBasicCompany(__company);
        ExperienceInitData memory data = abi.decode(initData, (ExperienceInitData));
        _vectorAddress = vector;
        world = _company.world();
        name = data.name;
        entryFee = data.entryFee;
        connectionDetails = data.connectionDetails;
    }

    function addHook(IExperienceHook _hook) external override onlyCompany notUpgraded {
        require(address(_hook) != address(0), "Experience: hook zero address");
        hook = _hook;
        emit HookAdded(address(hook));
    }

    function removeHook() external override onlyCompany notUpgraded {
        require(address(hook) != address(0), "Experience: hook not set");
        address a = address(hook);
        emit HookRemoved(a);
        delete hook;
    }

    function addPortalCondition(IPortalCondition condition) public onlyCompany notUpgraded {
        portalRegistry.addCondition(condition);
    }

    function removePortalCondition() public onlyCompany {
        portalRegistry.removeCondition();
    }

    function changePortalFee(uint256 fee) public onlyCompany {
        entryFee = fee;
        portalRegistry.changePortalFee(fee);
        emit PortalFeeChanged(fee);
    }

    function company() external view override returns (address) {
        return address(_company);
    }

    function vectorAddress() external view override returns (VectorAddress memory) {
        return _vectorAddress;
    }

    function entering(JumpEntryRequest memory request) external payable override nonReentrant onlyPortalRegistry notUpgraded returns (bytes memory)  {
        if(address(hook) != address(0)) {
            bool s = hook.beforeJumpEntry(address(this), request.sourceWorld, request.sourceCompany, request.avatar);
            require(s, "Experience: hook disallowed entry");
        }
        return connectionDetails;
    }

    function upgrade(bytes memory initData) external override onlyCompany notUpgraded {
        upgraded = true;
        experienceRegistry.upgradeExperience(initData);
    }

    function experienceUpgraded(address nextVersion) external override onlyRegistry {
        uint256 bal = address(this).balance;
        if(bal > 0) {
            payable(nextVersion).transfer(bal);
        }
        emit ExperienceUpgraded(address(this), nextVersion);
    }
}
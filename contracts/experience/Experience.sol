// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExperience, JumpEntryRequest} from './IExperience.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IBasicCompany} from './IBasicCompany.sol';
import {IBasicAvatar} from './IBasicAvatar.sol';
import {IExperienceHook} from './IExperienceHook.sol';

struct ExperienceInitData {
    string name;
    uint256 entryFee;
    bytes connectionDetails;
}

contract Experience is IExperience {

    //initialized when deploying master copy
    address public experienceFactory;
    address public portalRegistry;

    constructor(address _experienceFactory, address _portalRegistry) {
        require(_experienceFactory != address(0), "Experience: zero address factory");
        require(_portalRegistry != address(0), "Experience: zero address portalRegistry");
        experienceFactory = _experienceFactory;
        portalRegistry = _portalRegistry;
    }

    modifier onlyFactory() {
        require(msg.sender == experienceFactory, "Experience: caller is not the factory");
        _;
    }

    modifier onlyPortalRegistry() {
        require(msg.sender == portalRegistry, "Experience: caller is not the portal registry");
        _;
    }

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

    function addHook(IExperienceHook _hook) external override onlyCompany {
        require(address(_hook) != address(0), "Experience: hook zero address");
        hook = _hook;
        emit HookAdded(address(hook));
    }

    function removeHook() external override onlyCompany {
        require(address(hook) != address(0), "Experience: hook not set");
        address a = address(hook);
        emit HookRemoved(a);
        delete hook;
    }

    function company() external view override returns (address) {
        return address(_company);
    }

    function vectorAddress() external view override returns (VectorAddress memory) {
        return _vectorAddress;
    }

    function entering(JumpEntryRequest memory request) external payable override onlyPortalRegistry returns (bytes memory)  {
        if(address(hook) != address(0)) {
            bool s = hook.beforeJumpEntry(address(this), request.sourceWorld, request.sourceCompany, request.avatar);
            require(s, "Experience: hook disallowed entry");
        }
        IBasicAvatar(request.avatar).setLocation(_vectorAddress);
        return connectionDetails;
    }
}
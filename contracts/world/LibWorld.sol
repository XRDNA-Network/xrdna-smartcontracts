// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseProxyStorage, LibBaseProxy, LibProxyAccess} from '../libraries/LibBaseProxy.sol';
import {WorldRegistrationRequest} from './IWorldRegistry.sol';
import {WorldV1Storage, LibWorldV1Storage} from '../libraries/LibWorldV1Storage.sol';
import {RegistrationRenewalStorage, LibRegistration} from '../libraries/LibRegistration.sol';
import {CompanyRegistrationArgs} from './IWorld.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IWorldHook} from './IWorldHook.sol';
import {HookStorage, LibHooks} from '../libraries/LibHooks.sol';
import {CompanyRegistrationRequest, ICompanyRegistry} from '../company/ICompanyRegistry.sol';

library LibWorld {

    using LibProxyAccess for BaseProxyStorage;
    using LibRegistration for RegistrationRenewalStorage;
    using LibHooks for HookStorage;

    bytes32 public constant TERMS_COMPANY = keccak256("TERMS_COMPANY");
    bytes32 public constant TERMS_AVATAR = keccak256("TERMS_AVATAR");


    function init(WorldRegistrationRequest memory request) external {

        BaseProxyStorage storage bs = LibBaseProxy.load();

        require(request.owner != address(0), "World0_2: owner cannot be zero address");
        require(bytes(request.baseVector.x).length != 0, "World0_2: baseVector.x cannot be zero");
        require(bytes(request.baseVector.y).length != 0, "World0_2: baseVector.y cannot be zero");
        require(bytes(request.baseVector.z).length != 0, "World0_2: baseVector.z cannot be zero");
        require(request.baseVector.p == 0, "World0_2: baseVector.p must be zero");
        require(request.baseVector.p_sub == 0, "World0_2: baseVector.p_sub must be zero");
        require(bytes(request.name).length > 0, "World0_2: name cannot be empty");
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        ws.owner = request.owner;
        ws.baseVector = request.baseVector;
        ws.name = request.name;
        ws.nextP = 0;
        ws.active = true;
        ws.registrar = request.registrar;
        bs.grantRole(LibProxyAccess.ADMIN_ROLE, ws.owner);
        bs.grantRole(LibProxyAccess.SIGNER_ROLE, ws.owner);

        RegistrationRenewalStorage storage rs = LibRegistration.load();
        rs.setTerms(TERMS_COMPANY, request.companyTerms);
        rs.setTerms(TERMS_AVATAR, request.avatarTerms);
    }

    function registerCompany(
        CompanyRegistrationArgs memory args,
        ICompanyRegistry companyRegistry
    ) external returns (address company, VectorAddress memory vector) {
        require(args.owner != address(0), "World0_2: company owner cannot be zero address");
        require(bytes(args.name).length > 0, "World0_2: company name cannot be empty");
        WorldV1Storage storage ws = LibWorldV1Storage.load();
        
        IWorldHook hook =  IWorldHook(LibHooks.load().getHook());

        if(address(hook) != address(0)) {
            require(hook.beforeRegisterCompany(args), "World0_2: hook rejected company registration");
        }

        ++ws.nextP;
        vector = VectorAddress({
            x: ws.baseVector.x,
            y: ws.baseVector.y,
            z: ws.baseVector.z,
            t: ws.baseVector.t,
            p: ws.nextP, //increment for each new company
            p_sub: 0 //experience offset set to zero for new companies within a world
        });
        company = companyRegistry.registerCompany(CompanyRegistrationRequest({
            owner: args.owner,
            vector: vector,
            name: args.name,
            initData: args.initData
        }));
    }


}
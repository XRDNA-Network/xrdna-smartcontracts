// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IExperienceFactory} from './IExperienceFactory.sol';
import {IExperience} from './IExperience.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {IBasicCompany} from './IBasicCompany.sol';
import {IPortalRegistry, AddPortalRequest} from '../portal/IPortalRegistry.sol';
import {ICompanyRegistry} from '../company/ICompanyRegistry.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IExperienceRegistry, ExperienceInfo, RegisterExperienceRequest} from './IExperienceRegistry.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

struct ExperienceRegistryConstructorArgs {
    address mainAdmin;
    address experienceFactory;
    address compRegistry; 
    address portRegistry;
    address[] admins;
}

contract ExperienceRegistry is IExperienceRegistry, ReentrancyGuard, AccessControl {
    using LibVectorAddress for VectorAddress;
    using LibStringCase for string;

    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    ICompanyRegistry companyRegistry;
    IPortalRegistry portalRegistry;
    IExperienceFactory experienceFactory;
    
    // Mapping from vector address hash to experience details
    mapping(bytes32 => ExperienceInfo) public _experiencesByVectorHash;

    //mapping of experience info by its contract address
    mapping(address => ExperienceInfo) public experiencesByAddress;

    //enforce globally unique names
    mapping(string => ExperienceInfo) public experiencesByName;

    modifier onlyCompany() {
        require(companyRegistry.isRegisteredCompany(msg.sender), "ExperienceRegistry: caller is not a company");
        _;
    }

    modifier onlyExperience {
        require(isExperience(msg.sender), "ExperienceRegistry: caller is not an experience");
        _;
    }
    
    constructor(ExperienceRegistryConstructorArgs memory args) {
        require(args.mainAdmin != address(0), "ExperienceRegistry: main admin address cannot be 0");
        require(args.compRegistry != address(0), "ExperienceRegistry: company registry address cannot be 0");
        require(args.portRegistry != address(0), "ExperienceRegistry: portal registry address cannot be 0");
        require(args.experienceFactory != address(0), "ExperienceRegistry: experience factory address cannot be 0");
       
        companyRegistry = ICompanyRegistry(args.compRegistry);
        portalRegistry = IPortalRegistry(args.portRegistry);
        experienceFactory = IExperienceFactory(args.experienceFactory);
        _grantRole(DEFAULT_ADMIN_ROLE, args.mainAdmin);
        _grantRole(ADMIN_ROLE, args.mainAdmin);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), "ExperienceRegistry: admin address cannot be 0");
            _grantRole(ADMIN_ROLE, args.admins[i]);
        }
    }

    function currentExperienceVersion() public view override returns (uint256) {
        return experienceFactory.supportsVersion();
    }

    function setCompanyRegistry(ICompanyRegistry reg) public onlyRole(ADMIN_ROLE) {
        require(address(reg) != address(0), "ExperienceRegistry: zero address not valid");
        companyRegistry = reg;
    }

    function setPortalRegistry(IPortalRegistry reg) public onlyRole(ADMIN_ROLE) {
        require(address(reg) != address(0), "ExperienceRegistry: zero address not valid");
        portalRegistry = reg;
    }

    function setExperienceFactory(address factory) public onlyRole(ADMIN_ROLE) {
        require(factory != address(0), "ExperienceRegistry: zero address not valid");
        experienceFactory = IExperienceFactory(factory);
    }

    function isExperience(address exp) public view returns (bool) {
        return experiencesByAddress[exp].company != address(0);
    }

    function getExperienceByVector(VectorAddress memory vector) public view override returns (ExperienceInfo memory) {
        return _experiencesByVectorHash[keccak256(abi.encode(vector.asLookupKey()))];
    }

    function registerExperience(RegisterExperienceRequest memory request) public  onlyCompany nonReentrant returns(address, uint256) {
        IBasicCompany company = IBasicCompany(msg.sender);
        string memory lowerName = request.name.lower();
        /**
        * WARN: there is an issue with unicode or whitespace characters present in names. 
        * Off-chain verification should ensure that names are properly trimmed and
        * filtered with hidden characters if we truly want visually-unique names.
        */
        require(experiencesByName[lowerName].company == address(0), "ExperienceRegistry: experience name already exists");
        IExperience exp = IExperience(experienceFactory.createExperience(msg.sender, request.name, request.vector, request.initData));
        bytes32 hash = keccak256(abi.encode(request.vector.asLookupKey()));
        uint256 portalId = portalRegistry.addPortal(AddPortalRequest({
            destination: exp,
            fee: exp.entryFee()
        }));
        ExperienceInfo memory info = ExperienceInfo({
            company: msg.sender,
            world: company.world(),
            experience: exp,
            portalId: portalId
        });
        _experiencesByVectorHash[hash] = info;
        experiencesByAddress[address(exp)] = info;
        experiencesByName[lowerName] = info;
        emit ExperienceRegistered(company.world(), msg.sender, address(exp), exp.name());
        return (address(exp), portalId);
    }

    function upgradeExperience(bytes calldata initData) public onlyExperience nonReentrant {
        experienceFactory.upgradeExperience(msg.sender, initData);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IExperienceFactory} from './IExperienceFactory.sol';
import {IExperience} from './IExperience.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {IBasicCompany} from './IBasicCompany.sol';
import {IPortalRegistry, AddPortalRequest} from '../portal/IPortalRegistry.sol';

interface ICompanyRegistry {
    function isCompany(address a) external view returns (bool);
}

struct ExperienceInfo {
    address company;
    address world;
    IExperience experience;
    uint256 portalId;
}

contract ExperienceRegistry is AccessControl {
    using LibVectorAddress for VectorAddress;
    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    ICompanyRegistry companyRegistry;
    IPortalRegistry portalRegistry;
    IExperienceFactory experienceFactory;
    
    // Mapping from vector address hash to experience details
    mapping(bytes32 => ExperienceInfo) public experiencesByVectorHash;

    //mapping of experience info by its contract address
    mapping(address => ExperienceInfo) public experiencesByAddress;

    //psub counter for each company contract. Used to generate unique vector addresses for
    //each newly registered experience
    mapping(address => uint256) public companyVAPSubCounter;

    modifier onlyCompany() {
        require(companyRegistry.isCompany(msg.sender), "ExperienceRegistry: caller is not a company");
        _;
    }

    event ExperienceRegistered(address indexed world, address indexed company, address indexed experience, string name);

    constructor(address mainAdmin, address[] memory admins, address compRegistry, address portRegistry) {
        companyRegistry = ICompanyRegistry(compRegistry);
        portalRegistry = IPortalRegistry(portRegistry);
        require(mainAdmin != address(0), "ExperienceRegistry: main admin address cannot be 0");
        require(_grantRole(DEFAULT_ADMIN_ROLE, mainAdmin), "ExperienceRegistry: default admin role grant failed");
        require(_grantRole(ADMIN_ROLE, mainAdmin), "ExperienceRegistry: admin role grant failed");
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "ExperienceRegistry: admin address cannot be 0");
            require(_grantRole(ADMIN_ROLE, admins[i]), "ExperienceRegistry: admin role grant failed");
        }
    }

    function setCompanyRegistry(ICompanyRegistry reg) public onlyRole(ADMIN_ROLE) {
        require(address(reg) != address(0), "ExperienceRegistry: zero address not valid");
        companyRegistry = reg;
    }

    function setPortalRegistry(IPortalRegistry reg) public onlyRole(ADMIN_ROLE) {
        require(address(reg) != address(0), "ExperienceRegistry: zero address not valid");
        portalRegistry = reg;
    }

    function isExperience(address exp) public view returns (bool) {
        return experiencesByAddress[exp].company != address(0);
    }

    function getExperienceByVector(VectorAddress memory va) public view returns (IExperience) {
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
        return experiencesByVectorHash[hash].experience;
    }

    function registerExperience(bytes memory initData) public  onlyCompany {
        IBasicCompany company = IBasicCompany(msg.sender);
        ++companyVAPSubCounter[msg.sender];
        uint256 psub = companyVAPSubCounter[msg.sender];
        VectorAddress memory va = company.vectorAddress();
        va.p_sub = psub;
        IExperience exp = IExperience(experienceFactory.createExperience(msg.sender, va, initData));
        bytes32 hash = keccak256(abi.encode(va.asLookupKey()));
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
        experiencesByVectorHash[hash] = info;
        experiencesByAddress[address(exp)] = info;
        emit ExperienceRegistered(company.world(), msg.sender, address(exp), exp.name());
    }
}
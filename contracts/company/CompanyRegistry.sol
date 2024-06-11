// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICompanyRegistry, CompanyRegistrationRequest} from './ICompanyRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {ICompanyFactory} from './ICompanyFactory.sol';
import {IWorldRegistry0_2} from '../world/v0.2/IWorldRegistry0_2.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {CompanyInitArgs} from './ICompany.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {ICompany} from './ICompany.sol';

struct CompanyRegistryArgs {
    address mainAdmin;
    address companyFactory;
    address worldRegistry;
    address[] admins;
}

contract CompanyRegistry is ICompanyRegistry, ReentrancyGuard, AccessControl {
    using LibStringCase for string;
    using LibVectorAddress for VectorAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    ICompanyFactory public companyFactory;
    IWorldRegistry0_2 public worldRegistry;

    mapping(string => address) _companiesByName;
    mapping(address => bool) _companies;
    mapping(bytes32 => address) _companiesByVector;

    modifier onlyFactory {
        require(msg.sender == address(companyFactory), "CompanyRegistry: caller is not factory");
        _;
    }

    modifier onlyWorld {
        require(worldRegistry.isWorld(msg.sender), "CompanyRegistry: caller is not a world");
        _;
    }

    modifier onlyCompany {
        require(_companies[msg.sender], "CompanyRegistry: caller is not a company");
        _;
    }

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "CompanyRegistry: caller is not an admin");
        _;
    }

    constructor(CompanyRegistryArgs memory args) {
        require(args.mainAdmin != address(0), "CompanyRegistry: main admin address cannot be 0");
        _grantRole(DEFAULT_ADMIN_ROLE, args.mainAdmin);
        _grantRole(ADMIN_ROLE, args.mainAdmin);
        require(args.companyFactory != address(0), "CompanyRegistry: factory address cannot be 0");
        require(args.worldRegistry != address(0), "CompanyRegistry: world registry address cannot be 0");
        companyFactory = ICompanyFactory(args.companyFactory);
        worldRegistry = IWorldRegistry0_2(args.worldRegistry);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), "CompanyRegistry: admin address cannot be 0");
            _grantRole(ADMIN_ROLE, args.admins[i]);
        }
    }

    receive() external payable {}


    function isRegisteredCompany(address company) external view returns (bool) {
        return _companies[company];
    }

    function currentCompanyVersion() external view override returns (uint256) {
        return companyFactory.supportsVersion();
    }

    function setCompanyFactory(address factory) public onlyAdmin {
        require(factory != address(0), "CompanyRegistry: factory address cannot be 0");
        companyFactory = ICompanyFactory(factory);
    }

    function setWorldRegistry(address registry) public onlyAdmin {
        require(registry != address(0), "CompanyRegistry: world registry address cannot be 0");
        worldRegistry = IWorldRegistry0_2(registry);
    }

    

    function registerCompany(CompanyRegistrationRequest memory request) external payable onlyWorld nonReentrant returns (address) {
        string memory nm = request.name.lower();
        require(_companiesByName[nm] == address(0), "CompanyRegistry: company name already taken");
        address company = companyFactory.createCompany(CompanyInitArgs({
            owner: request.owner,
            world: msg.sender,
            vector: request.vector,
            initData: request.initData,
            name: request.name
        }));
        require(company != address(0), "CompanyRegistry: company creation failed");
        _companiesByName[nm] = company;
        _companies[company] = true;
        _companiesByVector[keccak256(bytes(request.vector.asLookupKey()))] = company;
        if(msg.value > 0) {
            if(request.sendTokensToCompanyOwner) {
                payable(request.owner).transfer(msg.value);
            } else {
                payable(company).transfer(msg.value);
            }
        }
        emit CompanyRegistered(company, request.vector);
        return company;
    }

    function upgradeCompany(bytes calldata initData) external onlyCompany nonReentrant {
        companyFactory.upgradeCompany(msg.sender, initData);
    }
}
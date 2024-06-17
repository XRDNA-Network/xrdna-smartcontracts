// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICompanyRegistry, CompanyRegistrationRequest} from './ICompanyRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {ICompanyFactory} from './ICompanyFactory.sol';
import {IWorldRegistryV2} from '../world/v0.2/IWorldRegistryV2.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {CompanyInitArgs} from './ICompany.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {ICompany} from './ICompany.sol';


/**
 * @dev Args for the company registry
 */
struct CompanyRegistryArgs {
    address mainAdmin;
    address companyFactory;
    address worldRegistry;
    address[] admins;
}

/**
 * @title CompanyRegistry
 * @dev Registry of companies. This contract is responsible for deploying new companies
 * and keeping track of the current version of the company implementations. The registry
 * is also responsible for upgrading companies to a new version.
 */
contract CompanyRegistry is ICompanyRegistry, ReentrancyGuard, AccessControl {
    using LibStringCase for string;
    using LibVectorAddress for VectorAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    ICompanyFactory public companyFactory;
    IWorldRegistryV2 public worldRegistry;

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
        worldRegistry = IWorldRegistryV2(args.worldRegistry);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), "CompanyRegistry: admin address cannot be 0");
            _grantRole(ADMIN_ROLE, args.admins[i]);
        }
    }
    
    receive() external payable {}

    /**
     * @inheritdoc ICompanyRegistry
     */
    function isRegisteredCompany(address company) external view returns (bool) {
        return _companies[company];
    }

    /**
     * @inheritdoc ICompanyRegistry
     */
    function currentCompanyVersion() external view override returns (uint256) {
        return companyFactory.supportsVersion();
    }

    /**
     * @inheritdoc ICompanyRegistry
     */
    function setCompanyFactory(address factory) public onlyAdmin {
        require(factory != address(0), "CompanyRegistry: factory address cannot be 0");
        companyFactory = ICompanyFactory(factory);
    }

    /**
     * @inheritdoc ICompanyRegistry
     */
    function setWorldRegistry(address registry) public onlyAdmin {
        require(registry != address(0), "CompanyRegistry: world registry address cannot be 0");
        worldRegistry = IWorldRegistryV2(registry);
    }

    /**
     * @inheritdoc ICompanyRegistry
     */
    function registerCompany(CompanyRegistrationRequest memory request) external payable onlyWorld nonReentrant returns (address) {
        string memory nm = request.name.lower();
        /**
        * WARN: there is an issue with unicode or whitespace characters present in names. 
        * Off-chain verification should ensure that names are properly trimmed and
        * filtered with hidden characters if we truly want visually-unique names.
        */
        
        require(_companiesByName[nm] == address(0), "CompanyRegistry: company name already taken");
        
        //create a new company proxy
        address company = companyFactory.createCompany(CompanyInitArgs({
            owner: request.owner,
            world: msg.sender,
            vector: request.vector,
            initData: request.initData,
            name: request.name
        }));
        require(company != address(0), "CompanyRegistry: company creation failed");

        //index by name, etc.
        _companiesByName[nm] = company;
        _companies[company] = true;
        _companiesByVector[keccak256(bytes(request.vector.asLookupKey()))] = company;
        if(msg.value > 0) {
            //transfer funds according to request
            if(request.sendTokensToCompanyOwner) {
                payable(request.owner).transfer(msg.value);
            } else {
                payable(company).transfer(msg.value);
            }
        }
        emit CompanyRegistered(company, request.vector);
        return company;
    }

    /**
     * @inheritdoc ICompanyRegistry
     */
    function deactivateCompany(address company) external onlyWorld nonReentrant {
        ICompany c = ICompany(company);
        require(c.world() == msg.sender, "CompanyRegistry: caller is not the parent world for company");
        require(_companies[company], "CompanyRegistry: company not registered");
        VectorAddress memory vector = c.vectorAddress();

        ICompany(company).deactivate();
        delete _companies[company];
        delete _companiesByName[ICompany(company).name().lower()];
        delete _companiesByVector[keccak256(bytes(vector.asLookupKey()))];
        emit CompanyDeactivated(company);
    }

    /**
     * @inheritdoc ICompanyRegistry
     */
    function reactivateCompany(address company) external onlyWorld nonReentrant {
        ICompany c = ICompany(company);
        require(c.world() == msg.sender, "CompanyRegistry: caller is not the parent world for company");
        require(!_companies[company], "CompanyRegistry: company already active");
        VectorAddress memory vector = c.vectorAddress();

        _companies[company] = true;
        _companiesByName[ICompany(company).name().lower()] = company;
        _companiesByVector[keccak256(bytes(vector.asLookupKey()))] = company;
        ICompany(company).reactivate();
        emit CompanyReactivated(company);
    }

    /**
     * @inheritdoc ICompanyRegistry
     */
    function upgradeCompany(bytes calldata initData) external onlyCompany nonReentrant {
        companyFactory.upgradeCompany(msg.sender, initData);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IExperienceFactory} from './IExperienceFactory.sol';
import {IExperience} from './IExperience.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {IPortalRegistry, AddPortalRequest} from '../portal/IPortalRegistry.sol';
import {IWorldRegistryV2} from '../world/v0.2/IWorldRegistryV2.sol';
import {IWorldV2} from '../world/v0.2/IWorldV2.sol';
import {ICompany} from '../company/ICompany.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IExperienceRegistry, ExperienceInfo, RegisterExperienceRequest} from './IExperienceRegistry.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {ICompany} from '../company/ICompany.sol';

//registry constructor args
struct ExperienceRegistryConstructorArgs {
    address mainAdmin;
    address experienceFactory;
    address worldRegistry; 
    address portRegistry;
    address[] admins;
}

/**
 * @title ExperienceRegistry
 * @dev Registry contract for Experiences
 */
contract ExperienceRegistry is IExperienceRegistry, ReentrancyGuard, AccessControl {
    using LibVectorAddress for VectorAddress;
    using LibStringCase for string;

    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IWorldRegistryV2 public worldRegistry;
    IPortalRegistry public portalRegistry;
    IExperienceFactory public experienceFactory;
    
    // Mapping from vector address hash to experience details
    mapping(bytes32 => ExperienceInfo) _experiencesByVectorHash;

    //mapping of experience info by its contract address
    mapping(address => ExperienceInfo) experiencesByAddress;

    //enforce globally unique names
    mapping(string => ExperienceInfo) experiencesByName;

    modifier onlyWorld() {
        require(worldRegistry.isWorld(msg.sender), "ExperienceRegistry: caller is not a registered world");
        _;
    }

    modifier onlyExperience {
        require(isExperience(msg.sender), "ExperienceRegistry: caller is not an experience");
        _;
    }
    
    constructor(ExperienceRegistryConstructorArgs memory args) {
        require(args.mainAdmin != address(0), "ExperienceRegistry: main admin address cannot be 0");
        require(args.worldRegistry != address(0), "ExperienceRegistry: world registry address cannot be 0");
        require(args.portRegistry != address(0), "ExperienceRegistry: portal registry address cannot be 0");
        require(args.experienceFactory != address(0), "ExperienceRegistry: experience factory address cannot be 0");
       
        worldRegistry = IWorldRegistryV2(args.worldRegistry);
        portalRegistry = IPortalRegistry(args.portRegistry);
        experienceFactory = IExperienceFactory(args.experienceFactory);
        _grantRole(DEFAULT_ADMIN_ROLE, args.mainAdmin);
        _grantRole(ADMIN_ROLE, args.mainAdmin);
        for (uint256 i = 0; i < args.admins.length; i++) {
            require(args.admins[i] != address(0), "ExperienceRegistry: admin address cannot be 0");
            _grantRole(ADMIN_ROLE, args.admins[i]);
        }
    }

    /**
        * @inheritdoc IExperienceRegistry
     */
    function currentExperienceVersion() public view override returns (uint256) {
        return experienceFactory.supportsVersion();
    }

    /**
        * @inheritdoc IExperienceRegistry
     */
    function setWorldRegistry(IWorldRegistryV2 reg) public onlyRole(ADMIN_ROLE) {
        require(address(reg) != address(0), "ExperienceRegistry: zero address not valid");
        worldRegistry = reg;
    }

    /**
        * @inheritdoc IExperienceRegistry
     */
    function setPortalRegistry(IPortalRegistry reg) public onlyRole(ADMIN_ROLE) {
        require(address(reg) != address(0), "ExperienceRegistry: zero address not valid");
        portalRegistry = reg;
    }

    /**
        * @inheritdoc IExperienceRegistry
     */
    function setExperienceFactory(address factory) public onlyRole(ADMIN_ROLE) {
        require(factory != address(0), "ExperienceRegistry: zero address not valid");
        experienceFactory = IExperienceFactory(factory);
    }

    /**
     * @inheritdoc IExperienceRegistry
     */
    function isExperience(address exp) public view returns (bool) {
        return experiencesByAddress[exp].company != address(0);
    }

    /**
     * @inheritdoc IExperienceRegistry
     */
    function getExperienceByVector(VectorAddress memory vector) public view override returns (ExperienceInfo memory) {
        return _experiencesByVectorHash[keccak256(abi.encode(vector.asLookupKey()))];
    }

    /**
     * @inheritdoc IExperienceRegistry
     */
    function getExperienceByAddress(address exp) public view override returns (ExperienceInfo memory) {
        return experiencesByAddress[exp];
    }

    /**
     * @inheritdoc IExperienceRegistry
     */
    function getExperiencesByName(string memory name) public view override returns (ExperienceInfo memory) {
        return experiencesByName[name.lower()];
    }

    /**
     * @inheritdoc IExperienceRegistry
     */
    function registerExperience(RegisterExperienceRequest memory request) public  onlyWorld nonReentrant returns(address, uint256) {
        ICompany company = ICompany(request.company);
        require(company.world() == msg.sender, "ExperienceRegistry: company is not registered with the calling world");
        string memory lowerName = request.name.lower();
        
        /**
        * WARN: there is an issue with unicode or whitespace characters present in names. 
        * Off-chain verification should ensure that names are properly trimmed and
        * filtered with hidden characters if we truly want visually-unique names.
        */
        require(experiencesByName[lowerName].company == address(0), "ExperienceRegistry: experience name already exists");
        IExperience exp = IExperience(experienceFactory.createExperience(request.company, request.name, request.vector, request.initData));
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
        emit RegistryExperienceRegistered(company.world(), msg.sender, address(exp), exp.name());
        return (address(exp), portalId);
    }

    /**
     * @inheritdoc IExperienceRegistry
     */
    function removeExperience(address company, address exp) public onlyWorld nonReentrant returns (uint256 portalId) {
        require(ICompany(company).world() == msg.sender, "ExperienceRegistry: company is not registered with the calling world");
        IExperience expContract = IExperience(exp);
        

        require(expContract.company() == company, "ExperienceRegistry: experience is not registered with the calling company");
        ExperienceInfo memory info = experiencesByAddress[exp];
        portalRegistry.removePortal(info.portalId);
        portalId = info.portalId;
        VectorAddress memory vector = expContract.vectorAddress();
        delete experiencesByAddress[exp];
        delete experiencesByName[expContract.name().lower()];
        delete _experiencesByVectorHash[keccak256(abi.encode(vector.asLookupKey()))];
        expContract.deactive();
        emit RegistryExperienceRemoved(exp, portalId);
    }

    /**
     * @inheritdoc IExperienceRegistry
     */
    function upgradeExperience(bytes calldata initData) public onlyExperience nonReentrant returns (address) {
        return experienceFactory.upgradeExperience(msg.sender, initData);
    }
}
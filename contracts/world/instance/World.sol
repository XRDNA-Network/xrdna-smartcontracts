// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {IWorld, WorldInitArgs, NewCompanyArgs, NewAvatarArgs, NewExperienceArgs} from './IWorld.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {ICompanyRegistry, CreateCompanyArgs} from '../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {WorldStorage, LibWorld} from './LibWorld.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {IAvatarRegistry, CreateAvatarArgs} from '../../avatar/registry/IAvatarRegistry.sol';
import {IExperienceRegistry, CreateExperienceArgs} from '../../experience/registry/IExperienceRegistry.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {IWorldRegistry} from '../registry/IWorldRegistry.sol';

struct WorldConstructorArgs {
    address registrarRegistry;
    address worldRegistry;
    address avatarRegistry;
    address companyRegistry;
    address experienceRegistry;
}


contract World is BaseRemovableEntity, IWorld {

    using LibVectorAddress for VectorAddress;

    IWorldRegistry public immutable worldRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    ICompanyRegistry public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;

    modifier onlyActiveCompany {
        require(companyRegistry.isRegistered(msg.sender), 'World: Company not registered');
        require(ICompany(msg.sender).isEntityActive(), 'World: Company not active');
        _;
    }

    constructor(WorldConstructorArgs memory args) {
        require(args.worldRegistry != address(0), 'World: Invalid world registry');
        require(args.avatarRegistry != address(0), 'World: Invalid avatar registry');
        require(args.companyRegistry != address(0), 'World: Invalid company registry');
        require(args.experienceRegistry != address(0), 'World: Invalid experience registry');
        worldRegistry = IWorldRegistry(args.worldRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }

    receive() external payable {}

    function upgrade(bytes calldata initData) public override onlyOwner {
        worldRegistry.upgradeEntity(initData);
    }

    function postUpgradeInit(bytes calldata) external override onlyRegistry {
        //no-op
    }
    
    function version() public pure override returns (Version memory) {
        return Version(1, 0);
    }

    function owningRegistry() internal view override returns (address) {
        return address(worldRegistry);
    }

    function init(WorldInitArgs memory args) public onlyRegistry {
        require(bytes(args.name).length > 0, 'World: Name required');
        require(args.owner != address(0), 'World: Owner required');
        require(args.termsOwner != address(0), 'World: Terms owner required');

        //false, false means p and p_sub must be 0
        args.vector.validate(false, false);

        LibEntity.load().name = args.name;
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = args.termsOwner;
        rs.vector = args.vector;
        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);
    }

    /**
     * @dev Returns the base vector for the world
     */
    function vectorAddress() public view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }
   
    /**
     * @dev Returns whether the world is still active
     */
    function isStillActive() public view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    /**
     * @dev Returns whether the given address is a signer for the world. The world is terms
     * owner for companies.
     */
    function isTermsOwnerSigner(address a) public view returns (bool) {
        return isSigner(a);
    }

    /**
     * @dev Allows withdraw of registration renewal fees
     */
    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Registrar: insufficient balance");
        payable(LibAccess.owner()).transfer(amount);
    }

    /**
     * @dev Registers a new company contract. Must be called by a world signer
     */
    function registerCompany(NewCompanyArgs memory args) public payable onlySigner nonReentrant returns (address company) {
       
        //get the base vector for this world
        VectorAddress memory base = vectorAddress();
        WorldStorage storage ws = LibWorld.load();

        //establish the next P value for the new company
        ++ws.nextPValue;

        //ane apply it to the copied vector address
        base.p = ws.nextPValue;

        //create the company in the registry
        company = companyRegistry.createCompany(CreateCompanyArgs({
            sendTokensToOwner: args.sendTokensToOwner,
            owner: args.owner,
            name: args.name,
            terms: args.terms,
            initData: args.initData,
            ownerTermsSignature: args.ownerTermsSignature,
            expiration: args.expiration,
            vector: base
        }));
        require(company != address(0), 'World: Company creation failed');

        //transfer any tokens if applicable
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(company).transfer(msg.value);
            }
        }

        emit WorldAddedCompany(company, args.owner, base);
    }

    /**
     * @dev Deactivates a company contract. Must be called by a world signer
     */
    function deactivateCompany(address company, string calldata reason) public onlySigner nonReentrant {
        companyRegistry.deactivateEntity(IRemovableEntity(company), reason);
        emit WorldDeactivatedCompany(company, reason);
    }

    /**
     * @dev Reactivates a company contract. Must be called by a world signer
     */
    function reactivateCompany(address company) public onlySigner nonReentrant {
        companyRegistry.reactivateEntity(IRemovableEntity(company));
        emit WorldReactivatedCompany(company);
    }

    /**
     * @dev Removes a company contract. Must be called by a world signer
     */
    function removeCompany(address company, string calldata reason) public onlySigner nonReentrant {
        companyRegistry.removeEntity(IRemovableEntity(company), reason);
        emit WorldRemovedCompany(company, reason);
    }

    /**
     * @dev Registers a new avatar contract. Must be called by a world signer
     */
    function registerAvatar(NewAvatarArgs memory args) public payable onlySigner nonReentrant returns (address avatar) {
        //have avatar registry create avatar
        avatar = avatarRegistry.createAvatar(CreateAvatarArgs({
            sendTokensToOwner: args.sendTokensToOwner,
            owner: args.owner,
            name: args.name,
            startingExperience: args.startingExperience,
            initData: args.initData
        }));
        require(avatar != address(0), 'World: Avatar creation failed');
        //transfer tokens if applicable
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(avatar).transfer(msg.value);
            }
        }

        emit WorldAddedAvatar(avatar, args.owner);
    }

    /**
     * @dev Add an experience to the world. This is called by the company offering the experience
     */
    function addExperience(NewExperienceArgs memory args) public onlyActiveCompany nonReentrant returns (address experience, uint256 portalId) {
        CreateExperienceArgs memory expArgs = CreateExperienceArgs({
            company: msg.sender,
            vector: args.vector,
            name: args.name,
            initData: args.initData
        });
        (experience, portalId) = experienceRegistry.createExperience(expArgs);
        emit IWorld.WorldAddedExperience(experience, msg.sender, portalId);
    }

    /**
     * @dev Deactivates a company contract. Must be called by owning company
     */
    function deactivateExperience(address experience, string calldata reason) public onlyActiveCompany nonReentrant {
        experienceRegistry.deactivateExperience(msg.sender, experience, reason);
        emit IWorld.WorldDeactivatedExperience(experience, msg.sender, reason);
    }

    /**
     * @dev Reactivates an experience contract. Must be called by owning company
     */
    function reactivateExperience(address experience) public onlyActiveCompany nonReentrant {
        experienceRegistry.reactivateExperience(msg.sender, experience);
        emit IWorld.WorldReactivatedExperience(experience, msg.sender);
    }

    /**
     * @dev Removes a experience contract. Must be called by owning company
     */
    function removeExperience(address experience, string calldata reason) public onlyActiveCompany nonReentrant returns (uint256 portalId) {
        portalId = experienceRegistry.removeExperience(msg.sender, experience, reason);
        emit IWorld.WorldRemovedExperience(experience, msg.sender, reason, portalId);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {IWorld, NewCompanyArgs, NewAvatarArgs, NewExperienceArgs, WorldInitArgs} from './IWorld.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {ICompanyRegistry, CreateCompanyArgs} from '../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {WorldStorage, LibWorld} from './LibWorld.sol';
import {LibEntityRemoval} from '../../libraries/LibEntityRemoval.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';

struct WorldConstructorArgs {
    address registrarRegistry;
    address worldRegistry;
    address avatarRegistry;
    address companyRegistry;
    address experienceRegistry;
}

contract World is BaseRemovableEntity, IWorld {

    address public immutable worldRegistry;
    address public immutable avatarRegistry;
    ICompanyRegistry public immutable companyRegistry;
    address public immutable experienceRegistry;

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
        worldRegistry = args.worldRegistry;
        avatarRegistry = args.avatarRegistry;
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        experienceRegistry = args.experienceRegistry;
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function owningRegistry() internal view override returns (address) {
        return worldRegistry;
    }

    function init(string calldata name, VectorAddress calldata vector, bytes calldata initData) external onlyRegistry {
        LibEntity.load().name = name;
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = msg.sender;
        rs.vector = vector;
        WorldInitArgs memory args = abi.decode(initData, (WorldInitArgs));
        LibAccess.initAccess(args.owner, args.admins);
    }

    function baseVector() external view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }
   

    function isStillActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isTermsOwnerSigner(address a) external view returns (bool) {
        return isSigner(a);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount >= address(this).balance, "Registrar: insufficient balance");
        payable(LibAccess.owner()).transfer(amount);
    }

    /**
     * @dev Registers a new company contract. Must be called by a world signer
     */
    function registerCompany(NewCompanyArgs memory args) external payable onlySigner returns (address company) {
       
        VectorAddress memory base = IWorld(address(this)).baseVector();
        WorldStorage storage ws = LibWorld.load();
        ++ws.nextPValue;
        base.p = ws.nextPValue;

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

        emit WorldAddedCompany(company, args.owner, base);
    }

    /**
     * @dev Deactivates a company contract. Must be called by a world signer
     */
    function deactivateCompany(address company, string calldata reason) external onlySigner {
        companyRegistry.deactivateEntity(IRemovableEntity(company), reason);
        emit WorldDeactivatedCompany(company, reason);
    }

    /**
     * @dev Reactivates a company contract. Must be called by a world signer
     */
    function reactivateCompany(address company) external onlySigner {
        companyRegistry.reactivateEntity(IRemovableEntity(company));
        emit WorldReactivatedCompany(company);
    }

    /**
     * @dev Removes a company contract. Must be called by a world signer
     */
    function removeCompany(address company, string calldata reason) external onlySigner {
        companyRegistry.removeEntity(IRemovableEntity(company), reason);
        emit WorldRemovedCompany(company, reason);
    }

    /**
     * @dev Registers a new avatar contract. Must be called by a world signer
     */
    function registerAvatar(NewAvatarArgs memory args) external payable onlySigner returns (address avatar) {
        
    }

    /**
     * @dev Add an experience to the world. This is called by the company offering the experience
     */
    function addExperience(NewExperienceArgs memory args) external payable onlyActiveCompany returns (address experience, uint256 portalId) {

    }

    /**
     * @dev Deactivates a company contract. Must be called by owning company
     */
    function deactivateExperience(address experience, string calldata reason) external onlyActiveCompany {

    }

    /**
     * @dev Reactivates an experience contract. Must be called by owning company
     */
    function reactivateExperience(address experience) external onlyActiveCompany {

    }

    /**
     * @dev Removes a experience contract. Must be called by owning company
     */
    function removeExperience(address experience, string calldata reason) external onlyActiveCompany returns (uint256 portalId) {
    
    }
}
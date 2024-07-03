// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityShell} from '../../base-types/EntityShell.sol';
import {IExtensionResolver} from '../../interfaces/IExtensionResolver.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {CommonInitArgs} from '../../interfaces/entity/IRegisteredEntity.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibVectorAddress, VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {ExperienceStorage, LibExperience} from './LibExperience.sol';
import {ExperienceInitArgs} from '../registry/IExperienceRegistry.sol';
import {IExperience} from './IExperience.sol';

struct ExperienceConstructorArgs {
    address extensionResolver;
    address owningRegistry;
    address companyRegistry; 
}

contract Experience  is EntityShell {
    
    using LibVectorAddress for VectorAddress;

    address public immutable experienceRegistry;
    ICompanyRegistry public immutable companyRegistry;
    
    modifier onlyRegistry {
        require(msg.sender == address(experienceRegistry), "Company: only world registry");
        _;
    }

    modifier onlyActiveOwningCompany {
        require(companyRegistry.isRegistered(msg.sender), "Company: caller is not a registered company");
        require(company() == msg.sender, "Company: caller is not the owning company");
        require(ICompany(msg.sender).isEntityActive(), "Company: company is not active");
        _;
    }

    constructor(ExperienceConstructorArgs memory args) EntityShell(IExtensionResolver(args.extensionResolver)) {
        
        require(args.owningRegistry != address(0), "Company: owningRegistry cannot be zero address");
        require(args.companyRegistry != address(0), "Company: companyRegistry cannot be zero address");
        companyRegistry = ICompanyRegistry(args.companyRegistry);      
        experienceRegistry = args.owningRegistry;
    }

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
    }   

    function name() external view returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function init(CommonInitArgs calldata args) external onlyRegistry {
        require(args.termsOwner != address(0), "Experience: terms owner is the zero address");
        require(bytes(args.name).length > 0, "Experience: name cannot be empty");

        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);

        //true, true means p and p_sub values must be > 0
        args.vector.validate(true, true);
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
        rs.vector = args.vector;
        rs.termsOwner = args.termsOwner;

        ExperienceInitArgs memory expArgs = abi.decode(args.initData, (ExperienceInitArgs));
        ExperienceStorage storage es = LibExperience.load();
        es.entryFee = expArgs.entryFee;
        es.connectionDetails = expArgs.connectionDetails;
    }


    /**
     * @dev Returns the company that controls this experience
     */
    function company() public view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    /**
     * @dev Returns the world that this experience is in
     */
    function world() public view returns (address) {
        return ICompany(LibRemovableEntity.load().termsOwner).world();
    }

    /**
     * @dev Returns the spatial vector address for this experience, which is derived
     * from its parent company and world.
     */
    function vectorAddress() public view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }

    /**
     * @dev Returns the entry fee for this experience
     */
    function entryFee() public view returns (uint256) {
        return LibExperience.load().entryFee;
    }

    /**
     * @dev Sets the connection details for the experience. This can only be called by the parent company contract
     */
    function setConnectionDetails(bytes memory details) external onlyActiveOwningCompany {
        LibExperience.load().connectionDetails = details;
        emit IExperience.ConnectionDetailsChanged(details);
    }

}
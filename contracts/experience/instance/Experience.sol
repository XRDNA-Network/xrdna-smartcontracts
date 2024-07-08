// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IExperience, JumpEntryRequest} from './IExperience.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {ExperienceStorage, LibExperience} from './LibExperience.sol';

struct ExperienceConstructorArgs {
    address companyRegistry;
    address experienceRegistry;
}

struct ExperienceInitArgs {
    uint256 entryFee;
    bytes connectionDetails;
}

contract Experience is BaseRemovableEntity, IExperience {
    
    address public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;

    modifier onlyCompany {
        require(LibRemovableEntity.load().termsOwner == msg.sender, 'Experience: Only company can call');
        require(ICompany(msg.sender).isEntityActive(), 'Experience: Company is not active');
        _;
    }

    modifier onlyPortalRegistry {
        //FIXME: Implement portal registry
        _;
    }

    constructor(ExperienceConstructorArgs memory args) {
        require(args.companyRegistry != address(0), 'Experience: Invalid company registry');
        require(args.experienceRegistry != address(0), 'Experience: Invalid experience registry');
        companyRegistry = args.companyRegistry;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    
    function init(string calldata name, address _world, VectorAddress calldata vector, bytes calldata initData) public onlyRegistry {
        LibEntity.load().name = name;   
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = _world;
        rs.vector = vector;
        ExperienceInitArgs memory args = abi.decode(initData, (ExperienceInitArgs));
        ExperienceStorage storage es = LibExperience.load();
        es.entryFee = args.entryFee;
        es.connectionDetails = args.connectionDetails;
    }

    function owningRegistry() internal view override returns (address) {
        return address(experienceRegistry);
    }

    /**
     * @dev Returns the company that controls this experience
     */
    function company() external view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    /**
     * @dev Returns the world that this experience is in
     */
    function world() external view returns (address) {
        return ICompany(LibRemovableEntity.load().termsOwner).world();
    }

    /**
     * @dev Returns the spatial vector address for this experience, which is derived
     * from its parent company and world.
     */
    function vectorAddress() external view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }


    /**
     * @dev Returns the entry fee for this experience
     */
    function entryFee() external view returns (uint256) {
        return LibExperience.load().entryFee;
    }

    /**
     * @dev Adds a portal condition to the experience. This can only be called by the parent company contract
     */
    function addPortalCondition(address condition) external onlyCompany {

    }

    /**
     * @dev Removes the portal condition from the experience. This can only be called by the parent company contract
     */
    function removePortalCondition() external onlyCompany {

    }

    /**
     * @dev Changes the portal fee for this experience. This can only be called by the parent company contract
     */
    function changePortalFee(uint256 fee) external onlyCompany {

    }

    /**
     * @dev Returns information on how to connect to the experience. This is dependent on
     * the client and company implementation and will likely need to be decoded by the
     * company's infrastructure or API when a client attempts to jump into the experience.
     */
    function connectionDetails() external view onlyCompany returns (bytes memory)  {

    }

    /**
     * @dev Sets the connection details for the experience. This can only be called by the parent company contract
     */
    function setConnectionDetails(bytes memory details) external onlyCompany {

    }

    /**
     * @dev Called when an avatar jumps into this experience. This can only be called by the 
     * portal registry so that any portal condition is evaluated before entering the experience.
     */
    function entering(JumpEntryRequest memory request) external payable onlyPortalRegistry returns (bytes memory) {

    }
    

}
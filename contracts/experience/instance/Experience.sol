// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {IExperience, ExperienceInitArgs, ExperienceInfo, JumpEntryRequest} from './IExperience.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {ExperienceStorage, LibExperience} from './LibExperience.sol';
import {IPortalRegistry, AddPortalRequest} from '../../portal/IPortalRegistry.sol';
import {IPortalCondition} from '../../portal/IPortalCondition.sol';
import {IRemovable} from '../../interfaces/entity/IRemovable.sol';

struct ExperienceConstructorArgs {
    address companyRegistry;
    address experienceRegistry;
    address portalRegistry;
}

struct ExperienceInitData {
    uint256 entryFee;
    bytes connectionDetails;
}

contract Experience is BaseRemovableEntity, IExperience {

    using LibVectorAddress for VectorAddress;
    
    address public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IPortalRegistry public immutable portalRegistry;  

    modifier onlyCompany {
        require(LibRemovableEntity.load().termsOwner == msg.sender, 'Experience: Only company can call');
        require(ICompany(msg.sender).isEntityActive(), 'Experience: Company is not active');
        _;
    }

    modifier onlyPortalRegistry {
        require(msg.sender == address(portalRegistry), 'Experience: Only portal registry can call');
        _;
    }

    constructor(ExperienceConstructorArgs memory args) {
        require(args.companyRegistry != address(0), 'Experience: Invalid company registry');
        require(args.experienceRegistry != address(0), 'Experience: Invalid experience registry');
        require(args.portalRegistry != address(0), 'Experience: Invalid portal registry');
        companyRegistry = args.companyRegistry;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        portalRegistry = IPortalRegistry(args.portalRegistry);
    }

    function version() public pure override returns (Version memory) {
        return Version(1, 0);
    }

    
    /**
     * @dev initialize storage for a new experience. This can only be called by the experience registry
     */
    function init(ExperienceInitArgs memory args) public onlyRegistry {
        require(bytes(args.name).length > 0, 'Experience: Invalid name');
        require(args.company != address(0), 'Experience: Invalid company');
        require(bytes(args.name).length > 0, 'Experience: Invalid name');
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        require(rs.termsOwner == address(0), 'Experience: Already initialized');

        //true,true means both p and p_sub must be > 0
        args.vector.validate(true, true);

        LibEntity.load().name = args.name;   
       
        rs.active = true;
        rs.termsOwner = args.company;
        rs.vector = args.vector;
        ExperienceInitData memory data = abi.decode(args.initData, (ExperienceInitData));
        ExperienceStorage storage es = LibExperience.load();
        es.entryFee = data.entryFee;
        es.connectionDetails = data.connectionDetails;
    }

    /**
     * @dev Initializes the portal for the experience. This can only be called by the experience registry
     * and must be called AFTER initialization. This is because the portal registry will require that 
     * the caller (this experience) is registered, and registration requires certain information about 
     * the experience that is set during initialization.
     */
    function initPortal() public override returns (uint256 portal) {
        
        ExperienceStorage storage es = LibExperience.load();
        //register new portal with the registry
        portal = portalRegistry.addPortal(AddPortalRequest({
            fee: es.entryFee
        }));
        es.portalId = portal;
    }

    /**
     * @dev Returns the portal id attached to this experience
     */
    function portalId() public view override returns (uint256) {
        return LibExperience.load().portalId;
    }

    /**
     * @dev Deactivates the experience. This can only be called by the experience registry. This also
     * deactivates the portal associated with the experience.
     */
    function deactivate(string calldata reason) public override(IRemovable, BaseRemovableEntity) onlyRegistry {
        //deactivate portal THEN experience
        portalRegistry.deactivatePortal(LibExperience.load().portalId, reason);
        super.deactivate(reason);
        
    }

    /**
     * @dev Reactivates the experience. This can only be called by the experience registry. This also
     * reactivates the portal associated with the experience.
     */
    function reactivate() public override(IRemovable, BaseRemovableEntity) onlyRegistry {
        //reactivate experience THEN portal
        super.reactivate();
        portalRegistry.reactivatePortal(LibExperience.load().portalId);
        
    }

    /**
     * @dev Removes the experience. This can only be called by the experience registry. This also
     * removes the portal associated with the experience.
     */
    function remove(string calldata reason) public override(IRemovable, BaseRemovableEntity) onlyRegistry {
        //remove portal THEN experience
        portalRegistry.removePortal(LibExperience.load().portalId, reason);
        super.remove(reason);
    }

    /**
     * @dev Returns information about this experience
     */
    function getExperienceInfo(address experience) external view override returns (ExperienceInfo memory) {
        return ExperienceInfo({
            company: company(),
            world: ICompany(company()).world(),
            portalId: portalRegistry.getIdForExperience(experience)
        });
    }

    /**
     * @dev Returns the owning registry for this entity
     */
    function owningRegistry() internal view override returns (address) {
        return address(experienceRegistry);
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
     * @dev Adds a portal condition to the experience. This can only be called by the parent company contract
     */
    function addPortalCondition(address condition) public onlyCompany {
        require(condition != address(0), 'Experience: Invalid condition');
        portalRegistry.addCondition(IPortalCondition(condition));
    }

    /**
     * @dev Removes the portal condition from the experience. This can only be called by the parent company contract
     */
    function removePortalCondition() public onlyCompany {
        portalRegistry.removeCondition();
    }

    /**
     * @dev Changes the portal fee for this experience. This can only be called by the parent company contract
     */
    function changePortalFee(uint256 fee) public onlyCompany {
        portalRegistry.changePortalFee(fee);
    }

    /**
     * @dev Returns information on how to connect to the experience. This is dependent on
     * the client and company implementation and will likely need to be decoded by the
     * company's infrastructure or API when a client attempts to jump into the experience.
     */
    function connectionDetails() public view returns (bytes memory)  {
        return LibExperience.load().connectionDetails;
    }

    /**
     * @dev Sets the connection details for the experience. This can only be called by the parent company contract
     */
    function setConnectionDetails(bytes memory details) public onlyCompany {
        LibExperience.load().connectionDetails = details;
    }

    /**
     * @dev Called when an avatar jumps into this experience. This can only be called by the 
     * portal registry so that any portal condition is evaluated before entering the experience.
     */
    function entering(JumpEntryRequest memory) public payable onlyPortalRegistry returns (bytes memory) {
        ExperienceStorage storage s = LibExperience.load();
        
        if(s.entryFee > 0) {
            require(msg.value == s.entryFee, "Experience: incorrect entry fee");
            payable(address(LibRemovableEntity.load().termsOwner)).transfer(msg.value);
        }
        return s.connectionDetails;
    }
    

}
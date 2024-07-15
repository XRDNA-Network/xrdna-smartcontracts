
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {RegistrationTerms} from '../../libraries/LibRegistration.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {ITermsOwner} from '../../interfaces/registry/ITermsOwner.sol';
import {IVectoredEntity} from '../../base-types/entity/IVectoredEntity.sol';


struct NewCompanyArgs {

    //whether any attached tokens for registration are sent to the company owner address or
    //to the company contract itself
    bool sendTokensToOwner;

    //owner of the company contract
    address owner;

    //company's globally unique name
    string name;

    //the terms of the company's registration
    RegistrationTerms terms;

    //signature of the company owner on the terms and registrar address
    bytes ownerTermsSignature;

    //signature expiration time in seconds
    uint256 expiration;

    //company contract init data, if any
    bytes initData;
}


struct NewAvatarArgs {

    //whether any attached tokens for registration are sent to the avatar owner address or
    //to the avatar contract itself
    bool sendTokensToOwner;

    //owner of the avatar contract
    address owner;
    
    //address of the experience where the avatar starts
    address startingExperience;

    //avatar's globally unique name
    string name;

    //avatar contract init data, if any
    bytes initData;
}


struct NewExperienceArgs {

    //the experience's vector address
    VectorAddress vector;

    //experience's globally unique name
    string name;

    //company contract init data, if any
    bytes initData;
}

struct WorldInitArgs {
    address owner; 
    address termsOwner;
    VectorAddress vector;
    string name;
    bytes initData;
}

/**
 * @title IWorld
    * @dev IWorld is the interface for a world contract. A world registers companies and avatars as well as
    * add experiences for companies. It is the registration terms authority for all companies.
 */
interface IWorld is IAccessControl, IVectoredEntity, IRemovableEntity, ITermsOwner  {

    event WorldAddedCompany(address indexed company, address indexed owner, VectorAddress vector);
    event WorldAddedAvatar(address indexed avatar, address indexed owner);

    event WorldAddedCompany(address indexed company, address indexed owner);
    event WorldDeactivatedCompany(address indexed company, string reason);
    event WorldReactivatedCompany(address indexed company);
    event WorldRemovedCompany(address indexed company, string reason);

    event WorldAddedExperience(address indexed experience, address indexed company, uint256 portalId);
    event WorldDeactivatedExperience(address indexed experience, address indexed company, string reason);
    event WorldReactivatedExperience(address indexed experience, address indexed company);
    event WorldRemovedExperience(address indexed experience, address indexed company, string reason, uint256 portalId);

    function init(WorldInitArgs memory args) external;
    function vectorAddress() external view returns (VectorAddress memory);
    function withdraw(uint256 amount) external;

    /**
     * @dev Registers a new company contract. Must be called by a world signer
     */
    function registerCompany(NewCompanyArgs memory args) external payable returns (address company);

    /**
     * @dev Deactivates a company contract. Must be called by a world signer
     */
    function deactivateCompany(address company, string calldata reason) external;

    /**
     * @dev Reactivates a company contract. Must be called by a world signer
     */
    function reactivateCompany(address company) external;

    /**
     * @dev Removes a company contract. Must be called by a world signer
     */
    function removeCompany(address company, string calldata reason) external;

    /**
     * @dev Registers a new avatar contract. Must be called by a world signer
     */
    function registerAvatar(NewAvatarArgs memory args) external payable returns (address avatar);

    /**
     * @dev Add an experience to the world. This is called by the company offering the experience
     */
    function addExperience(NewExperienceArgs memory args) external returns (address experience, uint256 portalId);

    /**
     * @dev Deactivates a company contract. Must be called by owning company
     */
    function deactivateExperience(address experience, string calldata reason) external;

    /**
     * @dev Reactivates an experience contract. Must be called by owning company
     */
    function reactivateExperience(address experience) external;

    /**
     * @dev Removes a experience contract. Must be called by owning company
     */
    function removeExperience(address experience, string calldata reason) external returns (uint256 portalId);
}
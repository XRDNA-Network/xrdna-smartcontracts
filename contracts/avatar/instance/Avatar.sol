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
import {IAvatarRegistry, AvatarInitArgs} from '../../avatar/registry/IAvatarRegistry.sol';
import {LibAvatar, AvatarStorage} from './LibAvatar.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';

struct AvatarConstructorArgs {
    address extensionResolver;
    address owningRegistry;
    address worldRegistry;
    address experienceRegistry;
}

contract Avatar  is EntityShell {
    
    using LibVectorAddress for VectorAddress;

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "Avatar: caller is not the owner");
        _;
    }

    IAvatarRegistry public immutable avatarRegistry;
    IWorldRegistry public immutable worldRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    //TODO: add experience registry
    
    modifier onlyRegistry {
        require(msg.sender == address(worldRegistry), "Company: only world registry");
        _;
    }

    constructor(AvatarConstructorArgs memory args) EntityShell(IExtensionResolver(args.extensionResolver)) {
        
        require(args.owningRegistry != address(0), "Avatar: owningRegistry cannot be zero address");
        require(args.worldRegistry != address(0), "Avatar: worldRegistry cannot be zero address");
        require(args.experienceRegistry != address(0), "Avatar: experienceRegistry cannot be zero address");
        worldRegistry = IWorldRegistry(args.owningRegistry);        
        avatarRegistry = IAvatarRegistry(args.owningRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
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

    function username() external view returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function init(CommonInitArgs calldata args) external onlyRegistry {
        require(args.termsOwner != address(0), "Company: terms owner is the zero address");
        require(bytes(args.name).length > 0, "Company: name cannot be empty");

        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);

        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
        rs.vector = args.vector;
        rs.termsOwner = args.termsOwner;

        AvatarStorage storage avs = LibAvatar.load();
        AvatarInitArgs memory initData = abi.decode(args.initData, (AvatarInitArgs));
        require(initData.defaultExperience != address(0), "Avatar: default experience cannot be zero address");
        require(experienceRegistry.isRegistered(initData.defaultExperience), "Avatar: default experience is not registered");
        require(IExperience(initData.defaultExperience).isEntityActive(), "Avatar: default experience is not active");
        avs.canReceiveTokensOutsideExperience = initData.canReceiveTokensOutsideExperience;
        avs.appearanceDetails = initData.appearanceDetails;
        avs.currentExperience = initData.defaultExperience;
    }


     /**
     * @dev get the Avatar's current experience location
     */
    function location() external view returns (address) {
        return LibAvatar.load().currentExperience;
    }

    /**
     * @dev get the Avatar's appearance details. These will be specific to the avatar
     * implementation off chain should be used by clients to render the avatar correctly.
     */
    function appearanceDetails() external view returns (bytes memory) {
        return LibAvatar.load().appearanceDetails;
    }

    /**
     * @dev Check whether an avatar can receive tokens when not in an experience that 
     * matches their current location. This prevents spamming of tokens to the avatar.
     */
    function canReceiveTokensOutsideOfExperience() external view returns (bool) {
        return LibAvatar.load().canReceiveTokensOutsideExperience;
    }

    /**
     * @dev Get the next signing nonce for a company signature.
     */
    function companySigningNonce(address signer) external view returns (uint256) {
        return LibAvatar.load().companyNonces[signer];
    }

    /**
     * @dev Get the next signing nonce for an avatar owner signature.
     */
    function avatarOwnerSigningNonce() external view returns (uint256) {
        return LibAvatar.load().ownerNonce;
    }

    
    /*
    function canAddWearable(Wearable calldata wearable) external view returns (bool);

   
    function addWearable(Wearable calldata wearable) external;

    
    function removeWearable(Wearable calldata wearable) external;

    
    function getWearables() external view returns (Wearable[] memory);

    function isWearing(Wearable calldata wearable) external view returns (bool);
    */

    /**
     * @dev Set whether the avatar can receive tokens when not in an experience that matches 
     * their current location.
     */
    function setCanReceiveTokensOutsideOfExperience(bool canReceive) external onlyOwner {
        LibAvatar.load().canReceiveTokensOutsideExperience = canReceive;
    }

    /**
     * @dev Set the appearance details of the avatar. This must be called by the avatar owner.
     */
    function setAppearanceDetails(bytes memory details) external onlyOwner  {
        LibAvatar.load().appearanceDetails = details;
    }
}
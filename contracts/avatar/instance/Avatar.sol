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
import {LibAvatar, AvatarStorage} from '../../libraries/LibAvatar.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {IAssetRegistry} from '../../asset/registry/IAssetRegistry.sol';

struct AvatarConstructorArgs {
    address extensionResolver;
    address owningRegistry;
    address worldRegistry;
    address experienceRegistry;
    address assetRegistry;
    address portalRegistry;
    address companyRegistry;
}

contract Avatar is EntityShell {
    
    using LibVectorAddress for VectorAddress;

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "Avatar: caller is not the owner");
        _;
    }

    IAvatarRegistry public immutable avatarRegistry;
    IWorldRegistry public immutable worldRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IAssetRegistry public immutable assetRegistry;
    address public immutable portalRegistry;
    address public immutable companyRegistry;
    
    modifier onlyRegistry {
        require(msg.sender == address(worldRegistry), "Company: only world registry");
        _;
    }

    constructor(AvatarConstructorArgs memory args) EntityShell(IExtensionResolver(args.extensionResolver)) {
        
        require(args.owningRegistry != address(0), "Avatar: owningRegistry cannot be zero address");
        require(args.worldRegistry != address(0), "Avatar: worldRegistry cannot be zero address");
        require(args.experienceRegistry != address(0), "Avatar: experienceRegistry cannot be zero address");
        require(args.assetRegistry != address(0), "Avatar: assetRegistry cannot be zero address");
        require(args.portalRegistry != address(0), "Avatar: portalRegistry cannot be zero address");
        require(args.companyRegistry != address(0), "Avatar: companyRegistry cannot be zero address");

        worldRegistry = IWorldRegistry(args.owningRegistry);        
        avatarRegistry = IAvatarRegistry(args.owningRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        assetRegistry = IAssetRegistry(args.assetRegistry);
        portalRegistry = args.portalRegistry;
        companyRegistry = args.companyRegistry;
    }

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
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
        rs.registry = address(avatarRegistry);

        AvatarStorage storage avs = LibAvatar.load();
        AvatarInitArgs memory initData = abi.decode(args.initData, (AvatarInitArgs));
        require(initData.defaultExperience != address(0), "Avatar: default experience cannot be zero address");
        require(experienceRegistry.isRegistered(initData.defaultExperience), "Avatar: default experience is not registered");
        require(IExperience(initData.defaultExperience).isEntityActive(), "Avatar: default experience is not active");
        avs.canReceiveTokensOutsideExperience = initData.canReceiveTokensOutsideExperience;
        avs.appearanceDetails = initData.appearanceDetails;
        avs.currentExperience = initData.defaultExperience;
    }
     
}
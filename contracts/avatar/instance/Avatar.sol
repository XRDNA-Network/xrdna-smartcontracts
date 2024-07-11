// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {BaseEntity} from '../../base-types/entity/BaseEntity.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {LibEntity, EntityStorage} from '../../libraries/LibEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {IAvatar, AvatarInitArgs, AvatarJumpRequest, DelegatedJumpRequest} from './IAvatar.sol';
import {LibAvatar, Wearable, AvatarStorage} from '../../libraries/LibAvatar.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {IAssetRegistry} from '../../asset/registry/IAssetRegistry.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {IAsset} from '../../asset/instance/IAsset.sol';
import {LibLinkedList, LinkedList} from '../../libraries/LibLinkedList.sol';
import {AssetCheckArgs} from '../../asset/IAssetCondition.sol';
import {IPortalRegistry} from '../../portal/IPortalRegistry.sol';
import {PortalInfo} from '../../libraries/LibPortal.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


/**
 * @dev avatar initialization arguments. This is the extra bytes of an avatar creation request.
 */
struct AvatarInitData {
    bool canReceiveTokensOutsideExperience;
    bytes appearanceDetails;
}

/**
 * @dev Avatar constructor arguments. These are mapped to immutable regitry addresses so that any
 * clone of the avatar can access the same registry contracts.
 */
struct AvatarConstructorArgs {
    address avatarRegistry;
    address companyRegistry;
    address experienceRegistry;
    address portalRegistry;
    address erc721Registry;
}

/**
 * @title Avatar
 * @dev Avatar provides the basic functionality for avatar management, including the 
 * ability to add and remove wearables, as well as the ability to jump between experiences.
 * Avatar contracts hold assets and can be used to represent a user in a virtual world.
 */
contract Avatar is BaseEntity, ReentrancyGuard, IAvatar {

    using LibLinkedList for LinkedList;
    using MessageHashUtils for bytes;
    
    address public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    ICompanyRegistry public immutable companyRegistry;
    IAssetRegistry public immutable erc721Registry;
    IPortalRegistry public immutable portalRegistry;

    modifier onlyActiveCompany {
        //make sure caller is an active registered company contract
        require(companyRegistry.isRegistered(msg.sender), 'Avatar: Company not registered');
        require(ICompany(msg.sender).isEntityActive(), 'Avatar: Company not active');
        _;
    }

    //Called once when deploying the avatar logic
    constructor(AvatarConstructorArgs memory args) {
        require(args.avatarRegistry != address(0), 'Company: Invalid avatar registry');
        require(args.experienceRegistry != address(0), 'Company: Invalid experience registry');
        require(args.companyRegistry != address(0), 'Company: Invalid company registry');
        require(args.erc721Registry != address(0), 'Company: Invalid ERC721 registry');
        require(args.portalRegistry != address(0), 'Company: Invalid portal registry');

        avatarRegistry = args.avatarRegistry;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        erc721Registry = IAssetRegistry(args.erc721Registry);
        portalRegistry = IPortalRegistry(args.portalRegistry);
    }


    function version() public pure override returns (Version memory) {
        return Version(1, 0);
    }

    /**
        * @dev Initialize the avatar. This is called by the avatar registry when creating a new avatar.
        * It is invoked through its proxy so that any storage updates are done in the proxy's address space.
     */
    function init(AvatarInitArgs memory args) public onlyRegistry {
        require(LibAccess.owner() == address(0), 'Avatar: Already initialized');
        require(args.owner != address(0), 'Avatar: Invalid owner');
        require(args.startingExperience != address(0), 'Avatar: Invalid starting experience');
        require(experienceRegistry.isRegistered(args.startingExperience), 'Avatar: Starting experience not registered');
        require(bytes(args.name).length > 0, 'Avatar: Name required');

        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);
        LibEntity.load().name = args.name;

        AvatarInitData memory data = abi.decode(args.initData, (AvatarInitData));

        //avatar-specific storage
        AvatarStorage storage s = LibAvatar.load();

        //whether the avatar can receive tokens outside of an experience (i.e. NFT airdrops)
        s.canReceiveTokensOutsideExperience = data.canReceiveTokensOutsideExperience;

        //the starting experience (e.g. a World lobby)
        s.currentExperience = args.startingExperience;

        //the appearance details of the avatar, specific to the avatar implementation
        s.appearanceDetails = data.appearanceDetails;

        //The max number of wearables an avatar can wear
        s.list.maxSize = 200;
    }

    
    /**
     * @dev Get the registry that owns this contract.
     */
    function owningRegistry() internal view override returns (address) {
        return avatarRegistry;
    }
    
     /**
     * @dev get the Avatar's unique username
     */
    function username() public view returns (string memory) {
        return LibEntity.load().name;
    }

    /**
     * @dev get the Avatar's current experience location
     */
    function location() public view returns (address) {
        return LibAvatar.load().currentExperience;
    }

    /**
     * @dev get the Avatar's appearance details. These will be specific to the avatar
     * implementation off chain should be used by clients to render the avatar correctly.
     */
    function appearanceDetails() public view returns (bytes memory) {
        return LibAvatar.load().appearanceDetails;
    }

    /**
     * @dev Check whether an avatar can receive tokens when not in an experience that 
     * matches their current location. This prevents spamming of tokens to the avatar.
     */
    function canReceiveTokensOutsideOfExperience() public view returns (bool) {
        return LibAvatar.load().canReceiveTokensOutsideExperience;
    }

    /**
     * @dev Get the next signing nonce for a company signature.
     */
    function companySigningNonce(address signer) public view returns (uint256) {
        return LibAvatar.load().companyNonces[signer];
    }

    /**
     * @dev Get the next signing nonce for an avatar owner signature.
     */
    function avatarOwnerSigningNonce() public view returns (uint256) {
        return LibAvatar.load().ownerNonce;
    }

    /**
     * @dev Get the list of wearables the avatar is currently wearing.
     */
    function getWearables() public view returns (Wearable[] memory) {
        AvatarStorage storage s = LibAvatar.load();
        return s.list.getAllItems();
    }

    /**
     * @dev Check if the avatar is wearing a specific wearable asset.
     */
    function isWearing(Wearable calldata wearable) public view returns (bool) {
        AvatarStorage storage s = LibAvatar.load();
        return s.list.contains(wearable);
    }

    /**
     * @dev Check if the avatar can wear the given asset 
     */
    function canAddWearable(Wearable calldata wearable) public view returns (bool) {
        require(wearable.asset != address(0), "Avatar: wearable asset cannot be zero address");
        require(wearable.tokenId > 0, "Avatar: wearable tokenId cannot be zero");
        require(erc721Registry.isRegistered(wearable.asset), "Avatar: wearable asset not registered");
        require(IAsset(wearable.asset).isEntityActive(), "Avatar: wearable asset not active");
        
        address loc = location();
        require(loc != address(0), "Avatar: location cannot be zero address");
        IExperience exp = IExperience(loc);
        //make sure the avatar can use the asset in the current experience
        require(IAsset(wearable.asset).canUseAsset(AssetCheckArgs({
            asset: wearable.asset, 
            world: exp.world(), 
            company: exp.company(), 
            experience: address(loc),
            avatar: address(this)
        })),"Avatar: wearable asset cannot be used by avatar");
        IERC721 wAsset = IERC721(wearable.asset);
        require(wAsset.ownerOf(wearable.tokenId) == address(this), "Avatar: wearable token not owned by avatar");
        return true;
    }

    /**
     * @dev Add a wearable asset to the avatar. This must be called by the avatar owner. 
     * This will revert if there are already 200 wearables configured.
     */
    function addWearable(Wearable calldata wearable) public onlyOwner  {
        canAddWearable(wearable);

        AvatarStorage storage s = LibAvatar.load();
        s.list.insert(wearable);
        emit IAvatar.WearableAdded(wearable.asset, wearable.tokenId);
    }

    /**
     * @dev Remove a wearable asset from the avatar. This must be called by the avatar owner.
     */
    function removeWearable(Wearable calldata wearable) public onlyOwner {
        require(wearable.asset != address(0), "Avatar: wearable asset cannot be zero address");
        require(wearable.tokenId > 0, "Avatar: wearable tokenId cannot be zero");
        AvatarStorage storage s = LibAvatar.load();
        s.list.remove(wearable);
        emit IAvatar.WearableRemoved(wearable.asset, wearable.tokenId);
    }
    

    /**
     * @dev Set whether the avatar can receive tokens when not in an experience that matches 
     * their current location.
     */
    function setCanReceiveTokensOutsideOfExperience(bool canReceive) public onlyOwner {
        LibAvatar.load().canReceiveTokensOutsideExperience = canReceive;
    }

    /**
     * @dev Set the appearance details of the avatar. This must be called by the avatar owner.
     */
    function setAppearanceDetails(bytes calldata details) public onlyOwner {
        LibAvatar.load().appearanceDetails = details;
        emit AppearanceChanged(details);
    }

    /**
     * @dev Move the avatar to a new experience. This must be called by the avatar owner.
     * If fees are required for the jump, they must be attached to the transaction or come
     * from the avatar contract balance.
     */
    function jump(AvatarJumpRequest memory request) public payable onlyOwner {
        PortalInfo memory portal = _verifyCompanySignature(request);

        require(request.agreedFee == portal.fee, "Avatar: agreed fee does not match portal fee");
        
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        AvatarStorage storage s = LibAvatar.load();
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        //have to set location AFTER jump success
        s.currentExperience = address(portal.destination);
        
        emit IAvatar.JumpSuccess(address(portal.destination), portal.fee, connectionDetails);
    }

    /**
     * @dev Company can pay for the avatar jump txn. This must be 
     * called by a registered company contract. The avatar owner must sign off on
     * the request using the owner nonce tracked by this contract. If fees are required
     * for the jump, they must be attached to the transaction or come from the avatar
     * contract balance. The avatar owner signature approves the transfer of funds if 
     * coming from avatar contract.
     */
    function delegateJump(DelegatedJumpRequest memory request) public payable onlyActiveCompany {
        _verifyAvatarSignature(request);
        PortalInfo memory portal = portalRegistry.getPortalInfoById(request.portalId);
        
        require(request.agreedFee == portal.fee, "Avatar: agreed fee does not match portal fee");

        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        AvatarStorage storage s = LibAvatar.load();
        
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        //have to set location AFTER jump success
        s.currentExperience = address(portal.destination);
        emit IAvatar.JumpSuccess(address(portal.destination), portal.fee, connectionDetails);
    }


    /**
     * @dev Withdraw funds from the avatar contract. This must be called by the avatar owner.
     */
    function withdraw(uint256 amount) public onlyOwner {
        require(amount >= address(this).balance, 'Avatar: Insufficient balance');
        payable(owner()).transfer(amount);
    }

    /**
     * @dev Receive ERC721 tokens sent to the avatar. This must be called by a registered
     * erc721 asset contract. If the avatar does not allow mints outside of its current
     * experience, the issuer for the calling asset must match the current experience's company. 
     */
    function onERC721Received(
        address ,
        address ,
        uint256 tokenId,
        bytes calldata 
    ) public override nonReentrant returns (bytes4) {
        AvatarStorage storage s = LibAvatar.load();
        //only registered assets can be received by avatars
        require(erc721Registry.isRegistered(msg.sender), "Avatar: ERC721 token not from registered asset");
        IERC721 asset = IERC721(msg.sender);
        //if can't receive tokens outside of experience, check if company matches
        if(!s.canReceiveTokensOutsideExperience) {
            address company = IAsset(msg.sender).issuer();
            IExperience loc = IExperience(s.currentExperience);
            require(company == loc.company(), "Avatar: cannot receive tokens outside of experience");
        }
        //make sure avatar owns the token before accepting it
        require(asset.ownerOf(tokenId) == address(this), "Avatar: ERC721 token not owned by avatar");
        return this.onERC721Received.selector;
    }

    /**
     * @dev Revoke ERC721 tokens sent to the avatar. This must be called by a registered
     * erc721 asset contract.
     */
    function onERC721Revoked(uint256 tokenId) public override nonReentrant {
        AvatarStorage storage s = LibAvatar.load();
        require(erc721Registry.isRegistered(msg.sender), "Avatar: only registered assets can call this function");
        IERC721 asset = IERC721(msg.sender);
        try asset.ownerOf(tokenId) returns (address) {
            revert('Avatar: ERC721 token still owned by avatar');
        } catch {
            s.list.remove(Wearable(address(asset), tokenId));       
        }
    
    }
    
    function _verifyCompanySignature(AvatarJumpRequest memory request) internal returns (PortalInfo memory portal) {
        
        //get the portal info for the destination experience
        portal = portalRegistry.getPortalInfoById(request.portalId);

        //get the destination experience's owning company
        ICompany company = ICompany(portal.destination.company());
        AvatarStorage storage s = LibAvatar.load();

        //increment company signing nonce to avoid replays
        uint256 nonce = s.companyNonces[address(company)];
        ++s.companyNonces[address(company)];

        //companies sign off and agree to the avatar jumping into the experience for the 
        //given fee. This signature happens off chain between avatar client and company 
        //infrastructure.
        bytes32 hash = keccak256(abi.encode(request.portalId, request.agreedFee, nonce));

        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        //make sure signer is a signer for the destination experience's company
        bytes32 sigHash = b.toEthSignedMessageHash();
        address r = ECDSA.recover(sigHash, request.destinationCompanySignature);
        require(company.isSigner(r), "Avatar: company signer is not authorized");
    }

    //verify the avatar owner signature for a jump request
    function _verifyAvatarSignature(DelegatedJumpRequest memory request) internal {
        AvatarStorage storage s = LibAvatar.load();

        //make sure cannot replay avatar signature
        uint256 nonce = s.ownerNonce;
        ++s.ownerNonce;

        //avatar is agreeing to jump into the given destination portal for the given
        //fee. This signature happens off chain between avatar client and company
        bytes32 hash = keccak256(abi.encode(request.portalId, request.agreedFee, nonce));

        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        address r = ECDSA.recover(sigHash, request.avatarOwnerSignature);
        //make sure signer is the avatar owner
        require(r == LibAccess.owner(), "Avatar: avatar signer is not owner");
    }
}
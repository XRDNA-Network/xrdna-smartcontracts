// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {BaseEntity} from '../../base-types/entity/BaseEntity.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {LibEntity, EntityStorage} from '../../libraries/LibEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IAvatar, AvatarJumpRequest, DelegatedJumpRequest} from './IAvatar.sol';
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


struct AvatarInitArgs {
    bool canReceiveTokensOutsideExperience;
    bytes appearanceDetails;
}

struct AvatarConstructorArgs {
    address avatarRegistry;
    address companyRegistry;
    address experienceRegistry;
    address portalRegistry;
    address erc721Registry;
}

contract Avatar is BaseEntity, ReentrancyGuard, IAvatar {

    using LibLinkedList for LinkedList;
    using MessageHashUtils for bytes;
    
    address public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    ICompanyRegistry public immutable companyRegistry;
    IAssetRegistry public immutable erc721Registry;
    IPortalRegistry public immutable portalRegistry;

    modifier onlyActiveCompany {
        require(companyRegistry.isRegistered(msg.sender), 'Avatar: Company not registered');
        require(ICompany(msg.sender).isEntityActive(), 'Avatar: Company not active');
        _;
    }

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

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function init(string calldata name, address _owner, address startingExperience, bytes calldata initData) external onlyRegistry {
        require(LibAccess.owner() == address(0), 'Avatar: Already initialized');
        require(_owner != address(0), 'Avatar: Invalid owner');
        require(startingExperience != address(0), 'Avatar: Invalid starting experience');
        
        address[] memory admins = new address[](0);
        LibAccess.initAccess(_owner, admins);
        EntityStorage storage es = LibEntity.load();
        es.name = name;

        AvatarInitArgs memory args = abi.decode(initData, (AvatarInitArgs));
        AvatarStorage storage s = LibAvatar.load();
        s.canReceiveTokensOutsideExperience = args.canReceiveTokensOutsideExperience;
        s.currentExperience = startingExperience;
        s.appearanceDetails = args.appearanceDetails;
    }

    
    function owningRegistry() internal view override returns (address) {
        return avatarRegistry;
    }
    
     /**
     * @dev get the Avatar's unique username
     */
    function username() external view returns (string memory) {
        return LibEntity.load().name;
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
        
        address loc = IAvatar(address(this)).location();
        require(loc != address(0), "Avatar: location cannot be zero address");
        IExperience exp = IExperience(loc);
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
    function setCanReceiveTokensOutsideOfExperience(bool canReceive) external onlyOwner {
        LibAvatar.load().canReceiveTokensOutsideExperience = canReceive;
    }

    /**
     * @dev Set the appearance details of the avatar. This must be called by the avatar owner.
     */
    function setAppearanceDetails(bytes calldata details) external onlyOwner {
        LibAvatar.load().appearanceDetails = details;
        emit AppearanceChanged(details);
    }

    /**
     * @dev Move the avatar to a new experience. This must be called by the avatar owner.
     * If fees are required for the jump, they must be attached to the transaction or come
     * from the avatar contract balance.
     */
    function jump(AvatarJumpRequest memory request) external payable onlyOwner {
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
     * @dev Company can pay for the avatar to jump to a new experience. This must be 
     * called by a registered company contract. The avatar owner must sign off on
     * the request using the owner nonce tracked by this contract. If fees are required
     * for the jump, they must be attached to the transaction or come from the avatar
     * contract balance. The avatar owner signature approves the transfer of funds if 
     * coming from avatar contract.
     */
    function delegateJump(DelegatedJumpRequest memory request) external payable onlyActiveCompany {
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
    function withdraw(uint256 amount) external onlyOwner {
        require(amount >= address(this).balance, 'Avatar: Insufficient balance');
        payable(owner()).transfer(amount);
    }

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
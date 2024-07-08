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


struct AvatarInitArgs {
    bool canReceiveTokensOutsideExperience;
    address defaultExperience;
    bytes appearanceDetails;
}

struct AvatarConstructorArgs {
    address avatarRegistry;
    address companyRegistry;
    address experienceRegistry;
    address erc721Registry;
}

contract Avatar is BaseEntity, ReentrancyGuard, IAvatar {

    using LibLinkedList for LinkedList;
    
    address public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    ICompanyRegistry public immutable companyRegistry;
    IAssetRegistry public immutable erc721Registry;

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

        avatarRegistry = args.avatarRegistry;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        erc721Registry = IAssetRegistry(args.erc721Registry);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function init(string calldata name, address _owner, address startingExperience, bytes calldata initData) external onlyRegistry {
        require(LibAccess.owner() == address(0), 'Avatar: Already initialized');
        require(_owner != address(0), 'Avatar: Invalid owner');
        require(startingExperience != address(0), 'Avatar: Invalid starting experience');
        
        address[] memory admins = new address[](1);
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

    
    function canAddWearable(Wearable calldata wearable) external view returns (bool) {
        
    }

   
    function addWearable(Wearable calldata wearable) external onlyOwner {

    }

    
    function removeWearable(Wearable calldata wearable) external onlyOwner {

    }

    
    function getWearables() external view returns (Wearable[] memory) {

    }

    function isWearing(Wearable calldata wearable) external view returns (bool) {

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
}
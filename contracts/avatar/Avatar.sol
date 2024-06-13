// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatar, AvatarJumpRequest, DelegatedJumpRequest} from './IAvatar.sol';
import {WearableLinkedList, Wearable} from './WearableLinkedList.sol';
import {IAvatarHook} from './IAvatarHook.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IPortalRegistry, PortalInfo} from '../portal/IPortalRegistry.sol';
import {IExperience} from '../experience/IExperience.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {ICompanyRegistry} from '../company/ICompanyRegistry.sol';
import {ICompany} from '../company/ICompany.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IAvatarRegistry} from './IAvatarRegistry.sol';
import {AvatarV1Storage, LibAvatarV1Storage} from '../libraries/LibAvatarV1Storage.sol';
import {BaseProxyStorage, LibBaseProxy, LibProxyAccess} from '../libraries/LibBaseProxy.sol';
import {IMultiAssetRegistry} from '../asset/IMultiAssetRegistry.sol';
import {AssetCheckArgs} from '../asset/IAssetCondition.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IBasicAsset} from '../asset/IBasicAsset.sol';
import {IExperienceRegistry} from '../experience/IExperienceRegistry.sol';
import {LibLinkedList, LinkedList} from '../libraries/LibLinkedList.sol';

/**
 * @dev Data structure for initializing an avatar contract
 */
struct AvatarInitData {
    //whether the avatar can receive tokens from a company that does not match its
    //current experience
    bool canReceiveTokensOutsideOfExperience;

    //specialized appearance details. This could be a URL, encoded model data, or 
    //whatever a World uses when registering an avatar instance.
    bytes appearanceDetails;
}

//various registries and factories held as immutable addresses for all avatar instances
struct BaseContructorArgs {
    address avatarFactory;
    address avatarRegistry;
    address experienceRegistry;
    address portalRegistry;
    address companyRegistry;
    address multiAssetRegistry;
}

/**
 * @title Avatar
 * @dev The Avatar contract represents a user's avatar in the metaverse. It is the primary
 * interface for interacting with the avatar's wearables, experiences, and other avatar
 * specific data. The avatar is a proxy contract that can be upgraded by the Avatar owner.
 * The avatar owner can set appearance details, move to new experiences, and 
 * add or remove wearables. The avatar can also receive ERC721 tokens from registered 
 * assets and companies.
 */
contract Avatar is IAvatar, ReentrancyGuard {
    using LibStringCase for string;
    using LibVectorAddress for VectorAddress;
    using MessageHashUtils for bytes;
    using LibLinkedList for LinkedList;

    //set on constructor of master copy of avatar
    address public immutable avatarFactory;
    IAvatarRegistry public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IPortalRegistry public immutable portalRegistry;
    ICompanyRegistry public immutable companyRegistry;
    IMultiAssetRegistry public immutable assetRegistry;
    uint256 public constant version = 1;


    modifier onlyFactory {
        require(msg.sender == avatarFactory, "Avatar: only factory can call this function");
        _;
    }

    modifier onlyRegistry {
        require(msg.sender == address(avatarRegistry), "Avatar: only registry can call this function");
        _;
    }

    modifier onlyOwner {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        require(msg.sender == s.owner, "Avatar: only owner can call this function");
        _;
    }

    modifier onlyCompany {
        require(companyRegistry.isRegisteredCompany(msg.sender), "Avatar: caller is not a registered company");
        _;
    }

    /*
     * @dev initializes immutable factory and registry addresses inherited by all instances
     * of avatar
     */
    constructor(BaseContructorArgs memory args) {
        require(args.avatarFactory != address(0), "Avatar: avatar factory cannot be zero address");
        require(args.experienceRegistry != address(0), "Avatar: experience registry cannot be zero address");
        require(args.portalRegistry != address(0), "Avatar: portal registry cannot be zero address");
        require(args.companyRegistry != address(0), "Avatar: company registry cannot be zero address");
        require(args.avatarRegistry != address(0), "Avatar: avatar registry cannot be zero address");
        require(args.multiAssetRegistry != address(0), "Avatar: multi-asset registry cannot be zero address");
        avatarFactory = args.avatarFactory;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        portalRegistry = IPortalRegistry(args.portalRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        assetRegistry = IMultiAssetRegistry(args.multiAssetRegistry);
    }

    /**
     * Avatars can receive funds when created and during operation.
     */
    receive() external payable {  }

    /**
     * @dev Initialize the avatar contract. This is called by the AvatarFactory when the avatar is created.
     * @param _owner The address of the avatar owner
     * @param defaultExperience The address of the default experience contract where the avatar starts
     * @param initData Initialization data to pass to the avatar contract
     */
    function init(address _owner, address defaultExperience, string memory _name, bytes memory initData) public override onlyFactory {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        require(s.owner == address(0), "Avatar: contract already initialized");

        AvatarInitData memory data = abi.decode(initData, (AvatarInitData));
        require(bytes(_name).length > 0, "Avatar: username cannot be empty");
        require(_owner != address(0), "Avatar: owner cannot be zero address");
        require(experienceRegistry.isExperience(defaultExperience), "Avatar: default experience is not a registered experience");
        s.username = _name;
        s.location = IExperience(defaultExperience);
        s.canReceiveTokensOutsideOfExperience = data.canReceiveTokensOutsideOfExperience;
        s.appearanceDetails = data.appearanceDetails;
        s.owner = _owner;
        s.list.maxSize = 200;
    }

    /**
     * @inheritdoc IAvatar
     */
    function canReceiveTokensOutsideOfExperience() public view override returns (bool) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.canReceiveTokensOutsideOfExperience;
    }

    /**
     * @inheritdoc IAvatar
     */
    function owner() public view override returns (address) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.owner;
    }

    /**
     * @inheritdoc IAvatar
     */
    function hook() public view returns (IAvatarHook) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.hook;
    }

    /**
     * @inheritdoc IAvatar
     */
    function username() public view override returns (string memory) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.username;
    }

    /**
     * @inheritdoc IAvatar
     */
    function appearanceDetails() public view override returns (bytes memory) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.appearanceDetails;
    }

    /**
     * @inheritdoc IAvatar
     */
    function companySigningNonce(address company) public view override returns (uint256) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.companySigningNonce[company];
    }

    /**
     * @inheritdoc IAvatar
     */
    function avatarOwnerSigningNonce() public view override returns (uint256) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.avatarOwnerSigningNonce;
    }

    /**
     * convenience function to encode init data
     */
    function encodeInitData(AvatarInitData memory data) public pure returns (bytes memory) {
        return abi.encode(data);
    }

    

    /**
     * @dev get the Avatar's current vector address location (i.e. the experience they are in)
     */
    function location() public view override returns (IExperience) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.location;
    }

    /**
     * @dev Get the address of all wearable assets configured for the avatar. There is a 
     * limit of 200 wearables per avatar due to gas restrictions.
     */
    function getWearables() public view override returns (Wearable[] memory) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.list.getAllItems();
    }

    /**
     * @dev Check if the avatar is wearing a specific wearable asset.
     */
    function isWearing(Wearable calldata wearable) public view override returns (bool) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        return s.list.contains(wearable);
    }

     /**
     * @dev Set whether the avatar can receive tokens when not in an experience that matches 
     * their current location.
     */
    function setCanReceiveTokensOutsideOfExperience(bool canReceive) public override onlyOwner {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        s.canReceiveTokensOutsideOfExperience = canReceive;
    }

    /**
     * @dev Set the appearance details of the avatar. This must be called by the avatar owner.
     */
    function setAppearanceDetails(bytes memory details) public override onlyOwner {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        s.appearanceDetails = details;
        emit AppearanceChanged(details);
    }

    /**
     * @dev Move the avatar to a new experience. This must be called by the avatar owner.
     * If fees are required for the jump, they must be attached to the transaction or come
     * from the avatar contract balance. Only signer of avatar can call this function to 
     * authorize fees and jump.
     */
    function jump(AvatarJumpRequest memory request) public override payable onlyOwner {
        
        PortalInfo memory portal = _verifyCompanySignature(request);
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        //have to set location AFTER jump success
        s.location = portal.destination;
        
        emit JumpSuccess(address(portal.destination), portal.fee, connectionDetails);
    }

    /**
     * @dev Company can pay for the avatar to jump to a new experience. This must be 
     * called by a registered company contract. The avatar owner must sign off on
     * the request using the owner nonce tracked by this contract. If fees are required
     * for the jump, they must be attached to the transaction or come from the avatar
     * contract balance. The avatar owner signature approves the transfer of funds if 
     * coming from avatar contract.
     */
    function delegateJump(DelegatedJumpRequest memory request) public override payable onlyCompany {
        _verifyAvatarSignature(request);

        //must be called from a valid company contract so company signer is authorized
        PortalInfo memory portal = portalRegistry.getPortalInfoById(request.portalId);
        
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        //have to set location AFTER jump success
        s.location = portal.destination;
        emit JumpSuccess(address(portal.destination), portal.fee, connectionDetails);
    }

    /**
     * @dev Add a wearable asset to the avatar. This must be called by the avatar owner. 
     * This will revert if there are already 200 wearables configured.
     */
    function addWearable(Wearable calldata wearable) public onlyOwner override  {
        require(wearable.asset != address(0), "Avatar: wearable asset cannot be zero address");
        require(wearable.tokenId > 0, "Avatar: wearable tokenId cannot be zero");
        IERC721 wAsset = IERC721(wearable.asset);
        IExperience loc = location();
        require(IBasicAsset(wearable.asset).canUseAsset(AssetCheckArgs({
            asset: wearable.asset, 
            world: loc.world(), 
            company: loc.company(), 
            experience: address(loc),
            avatar: address(this)
        })), "Avatar: wearable asset cannot be used by avatar");

        require(wAsset.ownerOf(wearable.tokenId) == address(this), "Avatar: wearable token not owned by avatar");
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        s.list.insert(wearable);
        emit WearableAdded(wearable.asset, wearable.tokenId);
    }

    /**
     * @dev Remove a wearable asset from the avatar. This must be called by the avatar owner.
     */
    function removeWearable(Wearable calldata wearable) public onlyOwner override {
        require(wearable.asset != address(0), "Avatar: wearable asset cannot be zero address");
        require(wearable.tokenId > 0, "Avatar: wearable tokenId cannot be zero");
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        s.list.remove(wearable);
        emit WearableRemoved(wearable.asset, wearable.tokenId);
    }

    /**
     * @inheritdoc IAvatar
     */
    function setHook(IAvatarHook _hook) public override onlyOwner {
        require(address(_hook) != address(0), "Avatar: hook cannot be zero address");
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        s.hook = IAvatarHook(_hook);
        emit HookSet(address(_hook));
    }

    /**
     * @inheritdoc IAvatar
     */
    function removeHook() public override onlyOwner {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        delete s.hook;
        emit HookRemoved();
    }

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address ,
        address ,
        uint256 tokenId,
        bytes calldata 
    ) public override nonReentrant returns (bytes4) {
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        //only registered assets can be received by avatars
        require(assetRegistry.isRegisteredAsset(msg.sender), "Avatar: ERC721 token not from registered asset");
        IERC721 asset = IERC721(msg.sender);
        //if can't receive tokens outside of experience, check if company matches
        if(!s.canReceiveTokensOutsideOfExperience) {
            address company = IBasicAsset(msg.sender).issuer();
            IExperience loc = s.location;
            require(company == loc.company(), "Avatar: cannot receive tokens outside of experience");
        }
        //make sure avatar owns the token before accepting it
        require(asset.ownerOf(tokenId) == address(this), "Avatar: ERC721 token not owned by avatar");
        if(address(s.hook) != address(0)) {
            //give hook the final say
            require(s.hook.onReceiveERC721(address(this), msg.sender, tokenId), "Avatar: hook rejected ERC721 token");
        }
        return this.onERC721Received.selector;
    }

    //verify the company signature for a jump request
    function _verifyCompanySignature(AvatarJumpRequest memory request) internal returns (PortalInfo memory portal) {
        
        //get the portal info for the destination experience
        portal = portalRegistry.getPortalInfoById(request.portalId);

        //get the destination experience's owning company
        ICompany company = ICompany(portal.destination.company());
        AvatarV1Storage storage s = LibAvatarV1Storage.load();

        //increment company signing nonce to avoid replays
        uint256 nonce = s.companySigningNonce[address(company)];
        ++s.companySigningNonce[address(company)];

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
        AvatarV1Storage storage s = LibAvatarV1Storage.load();

        //make sure cannot replay avatar signature
        uint256 nonce = s.avatarOwnerSigningNonce;
        ++s.avatarOwnerSigningNonce;

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
        require(r == s.owner, "Avatar: avatar signer is not owner");
    }

    /**
     * @inheritdoc IAvatar
     */
    function withdraw(uint256 amount) public override onlyOwner {
        require(amount <= address(this).balance, "Avatar: insufficient balance for withdrawal");
        AvatarV1Storage storage s = LibAvatarV1Storage.load();
        payable(s.owner).transfer(address(this).balance);
    }

    /**
     * @inheritdoc IAvatar
     */
    function upgrade(bytes calldata initData) public override onlyOwner {
        avatarRegistry.upgradeAvatar(initData);
    }

    /**
     * @inheritdoc IAvatar
     */
    function upgradeComplete(address nextVersion) public override onlyFactory {
       BaseProxyStorage storage ps = LibBaseProxy.load();
        address old = ps.implementation;   
       ps.implementation = nextVersion;
       emit AvatarUpgraded(old, nextVersion);
    }
}
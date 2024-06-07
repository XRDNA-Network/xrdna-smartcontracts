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
import {IERC721Asset} from '../asset/IERC721Asset.sol';

interface IExperienceRegistry {
    function isExperience(address e) external view returns (bool);
    function getExperienceByVector(VectorAddress memory location) external view returns (address);
}

struct AvatarInitData {
    string username;
    bool canReceiveTokensOutsideOfExperience;
    bytes appearanceDetails;
}

struct BaseContructorArgs {
    address avatarFactory;
    address avatarRegistry;
    address experienceRegistry;
    address portalRegistry;
    address companyRegistry;
}

contract Avatar is IAvatar, ReentrancyGuard, WearableLinkedList {
    using LibStringCase for string;
    using LibVectorAddress for VectorAddress;
    using MessageHashUtils for bytes;

    //set on constructor of master copy of avatar
    address public immutable avatarFactory;
    IAvatarRegistry public immutable avatarRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IPortalRegistry public immutable portalRegistry;
    ICompanyRegistry public immutable companyRegistry;


    modifier onlyFactory {
        require(msg.sender == avatarFactory, "Avatar: only factory can call this function");
        _;
    }

    //fields set by init data
    bool public canReceiveTokensOutsideOfExperience;
    bool public upgraded;
    address public owner;
    IExperience private _location;
    IAvatarHook public hook;
    string public username;
    bytes public appearanceDetails;
    mapping (address => uint256) public companySigningNonce;
    uint256 public avatarOwnerSigningNonce;

    modifier notUpgraded {
        require(!upgraded, "Avatar: contract has been upgraded");
        _;
    }

    modifier onlyRegistry {
        require(msg.sender == address(avatarRegistry), "Avatar: only registry can call this function");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Avatar: only owner can call this function");
        _;
    }

    constructor(BaseContructorArgs memory args) {
        require(args.avatarFactory != address(0), "Avatar: avatar factory cannot be zero address");
        require(args.experienceRegistry != address(0), "Avatar: experience registry cannot be zero address");
        require(args.portalRegistry != address(0), "Avatar: portal registry cannot be zero address");
        require(args.companyRegistry != address(0), "Avatar: company registry cannot be zero address");
        require(args.avatarRegistry != address(0), "Avatar: avatar registry cannot be zero address");
        avatarFactory = args.avatarFactory;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        portalRegistry = IPortalRegistry(args.portalRegistry);
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
    }

    receive() external payable {  }

    function encodeInitData(AvatarInitData memory data) public pure returns (bytes memory) {
        return abi.encode(data);
    }

    /**
     * @dev Initialize the avatar contract. This is called by the AvatarFactory when the avatar is created.
     * @param _owner The address of the avatar owner
     * @param defaultExperience The address of the default experience contract where the avatar starts
     * @param initData Initialization data to pass to the avatar contract
     */
    function init(address _owner, address defaultExperience, bytes memory initData) public override onlyFactory {
        require(owner == address(0), "Avatar: contract already initialized");

        AvatarInitData memory data = abi.decode(initData, (AvatarInitData));
        require(bytes(data.username).length > 0, "Avatar: username cannot be empty");
        require(_owner != address(0), "Avatar: owner cannot be zero address");
        require(experienceRegistry.isExperience(defaultExperience), "Avatar: default experience is not a registered experience");
        username = data.username.lower();
        _location = IExperience(defaultExperience);
        canReceiveTokensOutsideOfExperience = data.canReceiveTokensOutsideOfExperience;
        appearanceDetails = data.appearanceDetails;
        owner = _owner;
    }

    /**
     * @dev get the Avatar's current vector address location (i.e. the experience they are in)
     */
    function location() public view override returns (IExperience) {
        return _location;
    }

    /**
     * @dev Get the address of all wearable assets configured for the avatar. There is a 
     * limit of 200 wearables per avatar due to gas restrictions.
     */
    function getWearables() public view override returns (Wearable[] memory) {
        return getAllItems();
    }

    function isWearing(Wearable calldata wearable) public view override returns (bool) {
        return contains(wearable);
    }

     /**
     * @dev Set whether the avatar can receive tokens when not in an experience that matches 
     * their current location.
     */
    function setCanReceiveTokensOutsideOfExperience(bool canReceive) public override onlyOwner {
        canReceiveTokensOutsideOfExperience = canReceive;
    }

    /**
     * @dev Set the appearance details of the avatar. This must be called by the avatar owner.
     */
    function setAppearanceDetails(bytes memory) public override onlyOwner notUpgraded {
        appearanceDetails = appearanceDetails;
        emit AppearanceChanged(appearanceDetails);
    }

    /**
     * @dev Move the avatar to a new experience. This must be called by the avatar owner.
     * If fees are required for the jump, they must be attached to the transaction or come
     * from the avatar contract balance. Only signer of avatar can call this function to 
     * authorize fees and jump.
     */
    function jump(AvatarJumpRequest memory request) public override payable onlyOwner notUpgraded {
        
        PortalInfo memory portal = _verifyCompanySignature(request);
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        _location = portal.destination;
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        emit JumpSuccess(address(portal.destination), connectionDetails);
    }

    /**
     * @dev Company can pay for the avatar to jump to a new experience. This must be 
     * called by a registered company contract. The avatar owner must sign off on
     * the request using the owner nonce tracked by this contract. If fees are required
     * for the jump, they must be attached to the transaction or come from the avatar
     * contract balance. The avatar owner signature approves the transfer of funds if 
     * coming from avatar contract.
     */
    function delegateJump(DelegatedJumpRequest memory request) public override payable notUpgraded {
        _verifyAvatarSignature(request);

        //must be called from a valid company contract so company signer is authorized
        require(companyRegistry.isRegisteredCompany(msg.sender), "Avatar: caller is not a registered company");
        PortalInfo memory portal = portalRegistry.getPortalInfoById(request.portalId);
        
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        _location = portal.destination;
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        emit JumpSuccess(address(portal.destination), connectionDetails);
    }

    /**
     * @dev Add a wearable asset to the avatar. This must be called by the avatar owner. 
     * This will revert if there are already 200 wearables configured.
     */
    function addWearable(Wearable calldata wearable) public onlyOwner override  {
        require(wearable.asset != address(0), "Avatar: wearable asset cannot be zero address");
        require(wearable.tokenId > 0, "Avatar: wearable tokenId cannot be zero");
        IERC721Asset wAsset = IERC721Asset(wearable.asset);
        require(wAsset.ownerOf(wearable.tokenId) == address(this), "Avatar: wearable token not owned by avatar");
        insert(wearable);
    }

    /**
     * @dev Remove a wearable asset from the avatar. This must be called by the avatar owner.
     */
    function removeWearable(Wearable calldata wearable) public onlyOwner override {
        remove(wearable);
    }

    function setHook(IAvatarHook _hook) public override onlyOwner {
        require(address(_hook) != address(0), "Avatar: hook cannot be zero address");
        hook = IAvatarHook(_hook);
    }

    function removeHook() public override onlyOwner {
        delete hook;
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
        if(address(hook) != address(0)) {
            require(hook.onReceiveERC721(address(this), msg.sender, tokenId), "Avatar: hook rejected ERC721 token");
        }
        return this.onERC721Received.selector;
    }

    function _verifyCompanySignature(AvatarJumpRequest memory request) internal returns (PortalInfo memory portal) {
        portal = portalRegistry.getPortalInfoById(request.portalId);
        ICompany company = ICompany(portal.destination.company());
        uint256 nonce = companySigningNonce[address(company)];
        ++companySigningNonce[address(company)];
        bytes32 hash = keccak256(abi.encode(request.portalId, request.agreedFee, nonce));

        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        address r = ECDSA.recover(sigHash, request.destinationCompanySignature);
        require(company.isSigner(r), "Avatar: company signer is not authorized");
    }

    function _verifyAvatarSignature(DelegatedJumpRequest memory request) internal {
        uint256 nonce = avatarOwnerSigningNonce;
        ++avatarOwnerSigningNonce;
        bytes32 hash = keccak256(abi.encode(request.portalId, request.agreedFee, nonce));

        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        bytes32 sigHash = b.toEthSignedMessageHash();
        address r = ECDSA.recover(sigHash, request.avatarOwnerSignature);
        require(r == owner, "Avatar: avatar signer is not owner");
    }

    function withdraw(uint256 amount) public override onlyOwner {
        require(amount <= address(this).balance, "Avatar: insufficient balance for withdrawal");
        payable(owner).transfer(address(this).balance);
    }

    function upgrade(bytes calldata initData) public override onlyOwner notUpgraded() {
         upgraded = true;
        avatarRegistry.upgradeAvatar(initData);
    }

    function upgradeComplete(address nextVersion) public override onlyRegistry {
       
        uint256 bal = address(this).balance;
        if(bal > 0) {
            payable(nextVersion).transfer(bal);
        }
        require(nextVersion != address(this), "Avatar: next version must be different contract");
        emit AvatarUpgraded(address(this), nextVersion);
    }
}
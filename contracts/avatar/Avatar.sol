// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAvatar, AvatarJumpRequest, DelegatedJumpRequest} from './IAvatar.sol';
import {AddressLinkedList} from './AddressLinkedList.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IPortalRegistry, PortalInfo} from '../portal/IPortalRegistry.sol';
import {IExperience} from '../experience/IExperience.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

interface IExperienceRegistry {
    function isExperience(address e) external view returns (bool);
    function getExperienceByVector(VectorAddress memory location) external view returns (address);
}

interface IBasicCompany {
    function isSigner(address signer) external view returns (bool);
}

struct AvatarInitData {
    string username;
    bool canReceiveTokensOutsideOfExperience;
    bytes appearanceDetails;
}

contract Avatar is IAvatar, AccessControl, AddressLinkedList {
    using LibStringCase for string;
    using LibVectorAddress for VectorAddress;
    using MessageHashUtils for bytes;

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    //set on constructor of master copy of avatar
    address public immutable avatarFactory;
    IExperienceRegistry public immutable experienceRegistry;
    IPortalRegistry public immutable portalRegistry;

    modifier onlyFactory {
        require(msg.sender == avatarFactory, "Avatar: only factory can call this function");
        _;
    }

    //fields set by init data
    bool public canReceiveTokensOutsideOfExperience;
    address public owner;
    VectorAddress private _location;
    IExperience expectedJumpExperience;
    string public username;
    bytes public appearanceDetails;
    mapping (address => uint256) public companySigningNonce;
    uint256 public avatarOwnerSigningNonce;

    constructor(address _avatarFactory, address _experienceRegistry, address _portalRegistry) {
        require(_avatarFactory != address(0), "Avatar: avatar factory cannot be zero address");
        require(_experienceRegistry != address(0), "Avatar: experience registry cannot be zero address");
        require(_portalRegistry != address(0), "Avatar: portal registry cannot be zero address");
        avatarFactory = _avatarFactory;
        experienceRegistry = IExperienceRegistry(_experienceRegistry);
        portalRegistry = IPortalRegistry(_portalRegistry);
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
        AvatarInitData memory data = abi.decode(initData, (AvatarInitData));
        require(bytes(data.username).length > 0, "Avatar: username cannot be empty");
        require(_owner != address(0), "Avatar: owner cannot be zero address");
        require(experienceRegistry.isExperience(defaultExperience), "Avatar: default experience is not a registered experience");
        username = data.username.lower();
        _location = IExperience(defaultExperience).vectorAddress();
        require(_grantRole(SIGNER_ROLE, _owner), "Avatar: signer role grant failed");
        canReceiveTokensOutsideOfExperience = data.canReceiveTokensOutsideOfExperience;
        appearanceDetails = data.appearanceDetails;
        owner = _owner;
    }

    /**
     * @dev get the Avatar's current vector address location (i.e. the experience they are in)
     */
    function location() public view override returns (VectorAddress memory) {
        return _location;
    }

    /**
     * @dev Get the address of all wearable assets configured for the avatar. There is a 
     * limit of 200 wearables per avatar due to gas restrictions.
     */
    function getWearables() public view override returns (address[] memory) {
        return getAllItems();
    }

    /**
     * @dev Check whether the given address is an authorized signer for the avatar.
     */
    function isSigner(address signer) public view override returns (bool) {
        return hasRole(SIGNER_ROLE, signer);
    }

     /**
     * @dev Set whether the avatar can receive tokens when not in an experience that matches 
     * their current location.
     */
    function setCanReceiveTokensOutsideOfExperience(bool canReceive) public override onlyRole(SIGNER_ROLE) {
        canReceiveTokensOutsideOfExperience = canReceive;
    }

    /**
     * @dev Set the location of the avatar. This must be called by a registered experience contract.
     */
    function setLocation(VectorAddress memory loc) public override  {
        require(address(expectedJumpExperience) == msg.sender, "Avatar: caller is not a expected experience");
        require(loc.equals(expectedJumpExperience.vectorAddress()), "Avatar: location does not match expected experience location");
        _location = loc;
        emit LocationChanged(loc);
    }

    /**
     * @dev Set the appearance details of the avatar. This must be called by the avatar owner.
     */
    function setAppearanceDetails(bytes memory) public override onlyRole(SIGNER_ROLE) {
        appearanceDetails = appearanceDetails;
        emit AppearanceChanged(appearanceDetails);
    }

    /**
     * @dev Move the avatar to a new experience. This must be called by the avatar owner.
     * If fees are required for the jump, they must be attached to the transaction or come
     * from the avatar contract balance.
     */
    function jump(AvatarJumpRequest memory request) public override payable onlyRole(SIGNER_ROLE) {
        
        PortalInfo memory portal = _verifyCompanySignature(request);
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        expectedJumpExperience = portal.destination;
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        delete expectedJumpExperience;
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
    function delegateJump(DelegatedJumpRequest memory request) public override payable {
        _verifyAvatarSignature(request);
        PortalInfo memory portal = portalRegistry.getPortalInfoById(request.portalId);
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        expectedJumpExperience = portal.destination;
        bytes memory connectionDetails = portalRegistry.jumpRequest{value: portal.fee}(request.portalId);
        delete expectedJumpExperience;
        emit JumpSuccess(address(portal.destination), connectionDetails);
    }

    /**
     * @dev Add a wearable asset to the avatar. This must be called by the avatar owner. 
     * This will revert if there are already 200 wearables configured.
     */
    function addWearable(address wearable) public override  {
        insert(wearable);
    }

    /**
     * @dev Remove a wearable asset from the avatar. This must be called by the avatar owner.
     */
    function removeWearable(address wearable) public override {
        remove(wearable);
    }

    /**
     * @dev Add a signer to the avatar. This must be called by the avatar owner.
     */
    function addSigner(address signer) public override {
        require(signer != address(0), "Avatar: signer cannot be zero address");
        require(_grantRole(SIGNER_ROLE, signer), "Avatar: signer role grant failed");
    }

    /**
     * @dev Remove a signer from the avatar. This must be called by the avatar owner.
     */
    function removeSigner(address signer) public override {
        require(signer != address(0), "Avatar: signer cannot be zero address");
        require(_revokeRole(SIGNER_ROLE, signer), "Avatar: signer role revoke failed");
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
        uint256 ,
        bytes calldata 
    ) public override pure returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function _verifyCompanySignature(AvatarJumpRequest memory request) internal returns (PortalInfo memory portal) {
        portal = portalRegistry.getPortalInfoById(request.portalId);
        IBasicCompany company = IBasicCompany(portal.destination.company());
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
        require(isSigner(r), "Avatar: avatar signer is not authorized");
    }

    function withdraw(uint256 amount) public override onlyRole(SIGNER_ROLE) {
        require(amount <= address(this).balance, "Avatar: insufficient balance for withdrawal");
        payable(owner).transfer(address(this).balance);
    }
}
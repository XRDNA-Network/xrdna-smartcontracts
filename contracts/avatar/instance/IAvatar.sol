// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IAccessControl} from "../../interfaces/IAccessControl.sol";
import {IRegisteredEntity} from "../../interfaces/entity/IRegisteredEntity.sol";
import {Wearable} from '../../libraries/LibAvatar.sol';

/**
 * @dev Arguments for an avatar jump.
 */
struct AvatarJumpRequest {
    //the destination portal id
    uint256 portalId;

    //the fee for the jump, agreed between avatar owner and destination experience's company
    uint256 agreedFee;

    //the signature of the destination company agreeing to the jump terms
    bytes destinationCompanySignature;
}

/**
 * @dev Arguments for a delegated jump (i.e. company paying for txn)
 */
struct DelegatedJumpRequest {

    //the destination portal id
    uint256 portalId;

    //the fee for the jump, agreed between avatar owner and destination experience's company
    uint256 agreedFee;

    //the signature of the avatar owner agreeing to the jump terms
    bytes avatarOwnerSignature;
}

/**
 * @title IAvatar
 * @dev The Avatar interface.
 */
interface IAvatar is IERC721Receiver, IAccessControl, IRegisteredEntity {


    event WearableAdded(address indexed wearable, uint256 tokenId);
    event WearableRemoved(address indexed wearable, uint256 tokenId);
    event LocationChanged(address indexed location);
    event AppearanceChanged(bytes indexed appearanceDetails);
    event JumpSuccess(address indexed experience, uint256 indexed fee, bytes connectionDetails);

    /**
     * @dev Initialize the Avatar with the given parameters. This function should only be called once
     * after cloning a new avatar.
     */
    function init(string calldata name, address owner, address startingExperience, bytes calldata initData) external;
    
    /**
     * @dev get the Avatar's unique username
     */
    function username() external view returns (string memory);

    /**
     * @dev get the Avatar's current experience location
     */
    function location() external view returns (address);

    /**
     * @dev get the Avatar's appearance details. These will be specific to the avatar
     * implementation off chain should be used by clients to render the avatar correctly.
     */
    function appearanceDetails() external view returns (bytes memory);

    /**
     * @dev Check whether an avatar can receive tokens when not in an experience that 
     * matches their current location. This prevents spamming of tokens to the avatar.
     */
    function canReceiveTokensOutsideOfExperience() external view returns (bool);

    /**
     * @dev Get the next signing nonce for a company signature.
     */
    function companySigningNonce(address signer) external view returns (uint256);

    /**
     * @dev Get the next signing nonce for an avatar owner signature.
     */
    function avatarOwnerSigningNonce() external view returns (uint256);
    
    /**
     * @dev Determine if the given wearable can be used by the avatar.
     */
    function canAddWearable(Wearable calldata wearable) external view returns (bool);

    /**
     * @dev Add a new wearable to the avatar. This must be called by the avatar owner.
     */
    function addWearable(Wearable calldata wearable) external;
    
    /**
     * @dev Remove a wearable from the avatar. This must be called by the avatar owner.
     */
    function removeWearable(Wearable calldata wearable) external;

    /**
     * @dev Get the wearables currently worn by the avatar.
     */
    function getWearables() external view returns (Wearable[] memory);

    /**
     * @dev Check if the avatar is wearing a specific wearable.
     */
    function isWearing(Wearable calldata wearable) external view returns (bool);
    

    /**
     * @dev Set whether the avatar can receive tokens when not in an experience that matches 
     * their current location.
     */
    function setCanReceiveTokensOutsideOfExperience(bool canReceive) external;

    /**
     * @dev Set the appearance details of the avatar. This must be called by the avatar owner.
     */
    function setAppearanceDetails(bytes memory) external;

    /**
     * @dev Move the avatar to a new experience. This must be called by the avatar owner.
     * If fees are required for the jump, they must be attached to the transaction or come
     * from the avatar contract balance.
     */
    function jump(AvatarJumpRequest memory request) external payable;

    /**
     * @dev Company can pay for the avatar jump txn. This must be 
     * called by a registered company contract. The avatar owner must sign off on
     * the request using the owner nonce tracked by this contract. If fees are required
     * for the jump, they must be attached to the transaction or come from the avatar
     * contract balance. The avatar owner signature approves the transfer of funds if 
     * coming from avatar contract.
     */
    function delegateJump(DelegatedJumpRequest memory request) external payable;


    /**
     * @dev Withdraw funds from the avatar contract. This must be called by the avatar owner.
     */
    function withdraw(uint256 amount) external;

    
    /**
     * @dev called when IERC721 asset is revoked.
     */
     function onERC721Revoked(uint tokenId) external;
}
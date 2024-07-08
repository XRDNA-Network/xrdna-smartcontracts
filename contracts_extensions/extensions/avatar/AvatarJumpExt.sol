// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {Wearable, AvatarStorage, LibAvatar} from '../../libraries/LibAvatar.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {IAvatar, AvatarJumpRequest, DelegatedJumpRequest} from '../../avatar/instance/IAvatar.sol';
import {IAssetRegistry} from '../../asset/registry/IAssetRegistry.sol';
import {IAsset} from '../../asset/IAsset.sol';
import {AssetCheckArgs} from '../../interfaces/asset/IAssetCondition.sol';
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IExperience} from '../../experience/instance/IExperience.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';
import {IPortalRegistry} from '../../portal/registry/IPortalRegistry.sol';
import {PortalInfo} from '../../libraries/LibPortal.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AvatarJumpExt is IExtension {

    using MessageHashUtils for bytes;

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "Avatar: caller is not the owner");
        _;
    }

    modifier onlyCompany {
        address cr = IAvatar(address(this)).companyRegistry();
        require(cr != address(0), "Avatar: company registry not set");
        ICompanyRegistry companyRegistry = ICompanyRegistry(cr);
        require(companyRegistry.isRegistered(msg.sender), "Avatar: caller is not a registered company");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.AVATAR_JUMP,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](2);
        sigs[0] = SelectorInfo({
            selector: this.jump.selector,
            name: "jump(AvatarJumpRequest)"
        });
        sigs[1] = SelectorInfo({
            selector: this.delegateJump.selector,
            name: "delegateJump(DelegatedJumpRequest)"
        });
        

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    function upgrade(address myAddress) external {
        //no-op
    }

    /**
     * @dev Move the avatar to a new experience. This must be called by the avatar owner.
     * If fees are required for the jump, they must be attached to the transaction or come
     * from the avatar contract balance. Only signer of avatar can call this function to 
     * authorize fees and jump.
     */
    function jump(AvatarJumpRequest memory request) public payable onlyOwner {
        
        PortalInfo memory portal = _verifyCompanySignature(request);

        require(request.agreedFee == portal.fee, "Avatar: agreed fee does not match portal fee");
        
        if(portal.fee > 0) {
            uint256 bal = address(this).balance + msg.value;
            require(bal >= portal.fee, "Avatar: insufficient funds for jump fee");
        }
        AvatarStorage storage s = LibAvatar.load();
        address pr = IAvatar(address(this)).portalRegistry();
        IPortalRegistry portalRegistry = IPortalRegistry(pr);
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
    function delegateJump(DelegatedJumpRequest memory request) public payable onlyCompany {
        _verifyAvatarSignature(request);

        address pr = IAvatar(address(this)).portalRegistry();
        IPortalRegistry portalRegistry = IPortalRegistry(pr);

        //must be called from a valid company contract so company signer is authorized
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


    //verify the company signature for a jump request
    function _verifyCompanySignature(AvatarJumpRequest memory request) internal returns (PortalInfo memory portal) {
        
        //get the portal info for the destination experience
        address pr = IAvatar(address(this)).portalRegistry();
        IPortalRegistry portalRegistry = IPortalRegistry(pr);
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
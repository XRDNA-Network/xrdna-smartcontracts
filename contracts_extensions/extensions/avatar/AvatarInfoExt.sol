// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {Wearable, AvatarStorage, LibAvatar} from '../../libraries/LibAvatar.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {IAvatar} from '../../avatar/instance/IAvatar.sol';
import {IAssetRegistry} from '../../asset/registry/IAssetRegistry.sol';
import {IAsset} from '../../asset/IAsset.sol';
import {AssetCheckArgs} from '../../interfaces/asset/IAssetCondition.sol';
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IExperience} from '../../experience/instance/IExperience.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';

contract AvatarInfoExt is IExtension {


    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "Avatar: caller is not the owner");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.AVATAR_INFO,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](9);
        sigs[0] = SelectorInfo({
            selector: this.name.selector,
            name: "name()"
        });
        sigs[1] = SelectorInfo({
            selector: this.username.selector,
            name: "username()"
        });
        sigs[2] = SelectorInfo({
            selector: this.location.selector,
            name: "location()"
        });
        sigs[3] = SelectorInfo({
            selector: this.appearanceDetails.selector,
            name: "appearanceDetails()"
        });
        sigs[4] = SelectorInfo({
            selector: this.canReceiveTokensOutsideOfExperience.selector,
            name: "canReceiveTokensOutsideOfExperience()"
        });
        sigs[5] = SelectorInfo({
            selector: this.companySigningNonce.selector,
            name: "companySigningNonce(address)"
        });
        sigs[6] = SelectorInfo({
            selector: this.avatarOwnerSigningNonce.selector,
            name: "avatarOwnerSigningNonce()"
        });
        sigs[7] = SelectorInfo({
            selector: this.setCanReceiveTokensOutsideOfExperience.selector,
            name: "setCanReceiveTokensOutsideOfExperience(bool)"
        });
        sigs[8] = SelectorInfo({
            selector: this.setAppearanceDetails.selector,
            name: "setAppearanceDetails(bytes)"
        });

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    function upgrade(address myAddress) external {
        //no-op
    }

    function name() external view returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function username() external view returns (string memory) {
        return LibRemovableEntity.load().name;
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

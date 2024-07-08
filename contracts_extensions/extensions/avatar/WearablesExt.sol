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
import {LinkedList, LibLinkedList} from '../../libraries/LibLinkedList.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';

contract WearablesExt is IExtension {

    using LibLinkedList for LinkedList;

    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "Avatar: caller is not the owner");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.AVATAR_WEARABLES,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](5);
        sigs[0] = SelectorInfo({
            selector: this.addWearable.selector,
            name: "addWearable(Wearable)"
        });
        sigs[1] = SelectorInfo({
            selector: this.removeWearable.selector,
            name: "removeWearable(Wearable)"
        });
        sigs[2] = SelectorInfo({
            selector: this.getWearables.selector,
            name: "getWearables()"
        });
        sigs[3] = SelectorInfo({
            selector: this.isWearing.selector,
            name: "isWearing(Wearable)"
        });
        sigs[4] = SelectorInfo({
            selector: this.canAddWearable.selector,
            name: "canAddWearable(Wearable)"
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
     * @dev Get the address of all wearable assets configured for the avatar. There is a 
     * limit of 200 wearables per avatar due to gas restrictions.
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
        address a = IAvatar(address(this)).assetRegistry();
        IAssetRegistry assetRegistry = IAssetRegistry(a);
        require(assetRegistry.isRegistered(wearable.asset), "Avatar: wearable asset not registered");
        
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

}
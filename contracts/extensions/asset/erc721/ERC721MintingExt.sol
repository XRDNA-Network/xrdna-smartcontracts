// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {ExtensionMetadata} from '../../../interfaces/IExtension.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../../libraries/LibExtensionNames.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../../libraries/LibRemovableEntity.sol';
import {ERC721Storage, LibERC721} from '../../../libraries/LibERC721.sol';
import {IAsset} from '../../../asset/IAsset.sol';
import {IAvatar} from '../../../avatar/instance/IAvatar.sol';
import {BaseAssetMintingExt} from '../../asset/BaseAssetMintingExt.sol';
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721Asset} from '../../../asset/instance/erc721/IERC721Asset.sol';
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract ERC721MintingExt is BaseAssetMintingExt {

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ERC721_MINTING,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](3);
        sigs[0] = SelectorInfo({
            selector: this.canMint.selector,
            name: "canMint(address,bytes)"
        });
        sigs[1] = SelectorInfo({
            selector: this.mint.selector,
            name: "mint(address,bytes)"
        });
        sigs[2] = SelectorInfo({
            selector: this.revoke.selector,
            name: "revoke(address,bytes)"
        });

        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no-op
    }


    /**
     * @dev determine if the asset can be minted
     * @param to the address to mint to
     * data is not used in minting so it is ignored
     */
    function canMint(address to, bytes calldata) public view override returns (bool) {
        require(to != address(0), "NTERC721Asset: mint to the zero address");
        if(IAsset(address(this)).avatarRegistry().isRegistered(to)) {
            IAvatar avatar = IAvatar(to);
            if(!avatar.canReceiveTokensOutsideOfExperience()) {
                _verifyAvatarLocationMatchesIssuer(IAvatar(to));
            }
        }
        return true;
    }

    /**
     * @dev Mints NFT to the specified address. This can only be called by the issuer
     * @param to the address to mint tokens to
     * @param data the data to use for minting, which should be an encoded uint256 amount
     */
    function mint(address to, bytes calldata data) public nonReentrant onlyIssuer {
        require(canMint(to, data), "NTERC721Asset: cannot mint to address");
        ERC721Storage storage s = LibERC721.load();
        
        ++s.tokenIdCounter;
        uint256 id = s.tokenIdCounter;
        _safeMint(to, id);
    }

     /**
     * @dev Revokes NFT from the specified address. This can only be called by the issuer
     * @param holder the address to revoke NFT from
     * @param data the data to use for revoking, which should be an encoded uint256 tokenId
     * This call is used when asset is transferred on original chain and the company needs
     * to keep the recipients assets in sync. An oracle will likely be used to ensure the
     * ownership synchronized.
     */
    function revoke(address holder, bytes calldata data) public nonReentrant onlyIssuer {
        (uint256 tokenId) = abi.decode(data, (uint256));
        require(holder != address(0), "NTERC721Asset: token does not exist");
        address owner = LibERC721.requireOwned(tokenId);
        require(owner == holder, "NTERC721Asset: not the owner of token id provided");
        
        _burn(tokenId);
        
        if (IAsset(address(this)).avatarRegistry().isRegistered(holder)) {
            // Notify the avatar that the token has been revoked and remove it from wearables
            IAvatar(holder).onERC721Revoked(tokenId);
        }
        
    }
     

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert IERC721Errors.ERC721InvalidReceiver(address(0));
        }
        address previousOwner = LibERC721._update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert IERC721Errors.ERC721InvalidSender(address(0));
        }
        emit IERC721Asset.ERC721Minted(to, tokenId);
    }


    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal {
        address previousOwner = LibERC721._update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert IERC721Errors.ERC721NonexistentToken(tokenId);
        }
    }

     /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}
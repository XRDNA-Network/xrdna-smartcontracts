// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {BaseAsset, BaseAssetConstructorArgs, BaseInitArgs} from '../BaseAsset.sol';
import {Version} from '../../../libraries/LibVersion.sol';
import {IAvatar} from '../../../avatar/instance/IAvatar.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../../libraries/LibRemovableEntity.sol';
import {LibAsset, AssetStorage} from '../../../libraries/LibAsset.sol';
import {LibERC721, ERC721Storage} from '../../../libraries/LibERC721.sol';
import {AssetInitArgs} from '../IAsset.sol';
import {IERC721Asset} from './IERC721Asset.sol';
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';



struct ERC721InitData {
    //baseURI cannot be empty
    string baseURI;
}

/**
 * @title NTERC721Asset
    * @dev NTERC721Asset represents a synthetic asset for any XR chain ERC721 tokens.
 */
contract NTERC721Asset is BaseAsset, ReentrancyGuard, IERC721Asset {

    using Strings for uint256;
    
    constructor(BaseAssetConstructorArgs memory args) BaseAsset(args) {   }

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
    }

    /**
     * @dev Initialize the state for the ERC721 asset. NOTE: this is called on the asset's proxy and 
     * falls back to this version of the asset implementation. This is called when a new asset is 
     * created in the ERC721 registry and its proxy is cloned. This implementation is set on the proxy
     * and the init method is called in the context of the proxy (i.e. using proxy's storage).
     */
    function init(AssetInitArgs calldata args) external onlyRegistry {
        
        ERC721InitData memory initData = abi.decode(args.initData, (ERC721InitData));
        
        initBase(BaseInitArgs({
            issuer: args.issuer,
            name: args.name,
            symbol: args.symbol,
            originAddress: args.originAddress,
            originChainId: args.originChainId
        }));

        ERC721Storage storage ercStore = LibERC721.load();
        require(bytes(initData.baseURI).length > 0, "NTERC721Asset: base URI must be set");
         if(!_endsWith(initData.baseURI, "/")) {
            ercStore.baseURI = string.concat(initData.baseURI, "/");
        } else {
            ercStore.baseURI = initData.baseURI;
        }
    }

    /**
     * @inheritdoc IERC721Asset
     */
    function supportsInterface(bytes4 interfaceId) public view virtual  returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) {
            revert IERC721Errors.ERC721InvalidOwner(address(0));
        }
        ERC721Storage storage s = LibERC721.load();
        return s.balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return LibERC721.requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        LibERC721.requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return LibERC721.load().baseURI;
    }

    /**
     * @dev determine if the asset can be minted
     * @param to the address to mint to
     * data is not used in minting so it is ignored
     */
    function canMint(address to) public view override returns (bool) {
        require(to != address(0), "NTERC721Asset: mint to the zero address");
        if(avatarRegistry.isRegistered(to)) {
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
     */
    function mint(address to) public nonReentrant onlyIssuer {
        require(canMint(to), "NTERC721Asset: cannot mint to address");
        ERC721Storage storage s = LibERC721.load();
        
        ++s.tokenIdCounter;
        uint256 id = s.tokenIdCounter;
        _safeMint(to, id);
    }

     /**
     * @dev Revokes NFT from the specified address. This can only be called by the issuer
     * @param holder the address to revoke NFT from
     */
    function revoke(address holder, uint256 tokenId) public nonReentrant onlyIssuer {
        require(holder != address(0), "NTERC721Asset: token does not exist");
        require(tokenId != 0, "NTERC721Asset: token id cannot be zero");
        address owner = LibERC721.requireOwned(tokenId);
        require(owner == holder, "NTERC721Asset: not the owner of token id provided");
        
        _burn(tokenId);
        
        if (avatarRegistry.isRegistered(holder)) {
            // Notify the avatar that the token has been revoked and remove it from wearables
            IAvatar(holder).onERC721Revoked(tokenId);
        }
        
    }

    function approve(address, uint256) public pure returns (bool) {
        revert("NTERC721: token is non-transferable");
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        LibERC721.requireOwned(tokenId);

        return LibERC721._getApproved(tokenId);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return LibERC721.load().operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address, bool) public virtual {
        revert("NTERC721: token is non-transferable");
    }


    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address, address, uint256) public pure returns (bool) {
        revert("NTERC721: token is non-transferable");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address, address, uint256, bytes memory) public virtual {
        revert("NTERC721: token is non-transferable");
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

    //internal helper to verify that the string ends with a suffix value
    function _endsWith(string memory str, string memory suffix) internal pure returns (bool) {
        return bytes(str).length >= bytes(suffix).length && bytes(str)[bytes(str).length - bytes(suffix).length] == bytes(suffix)[0];
    }

}
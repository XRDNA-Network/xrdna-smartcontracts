// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {IAssetHook} from './IAssetHook.sol';
import {IAvatarRegistry} from '../avatar/IAvatarRegistry.sol';
import {IAvatar} from '../avatar/IAvatar.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IExperience} from '../experience/IExperience.sol';

struct ERC721InitData {
    address issuer;
    address originChainAddress;
    uint256 originChainId;
    string name;
    string symbol;
    string baseURI;
}

interface IExperienceRegistry {
    function getExperienceByVector(VectorAddress memory va) external view returns (IExperience);
}

interface IUpgradedERC721 {
    function setStartingTokenId(uint256 tokenId) external;
}

contract NonTransferableERC721Asset is IERC721, IERC721Metadata, IERC721Errors {
    using Strings for uint256;

    address public immutable assetFactory;
    address public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    IExperienceRegistry public experienceRegistry;

    modifier onlyFactory() {
        require(msg.sender == assetFactory, "NonTransferableERC721: only factory allowed");
        _;
    }

    modifier onlyRegistry() {
        require(msg.sender == assetRegistry, "NonTransferableERC721: only registry allowed");
        _;
    }

    //once upgraded, no new tokens can be minted on this base contract
    bool public upgraded;

    //only authority allowed to issue tokens (refers to company contract)
    address public issuer;

    //optional hook installed to extend mint and transfer functionality
    IAssetHook public hook;

    //origin chain contract address
    address public originAddress;

    //original chain id
    uint256 public originChainId;

    // Token ID counter
    uint256 _tokenIdCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    //assigned base URI for asset media. Should be different from original NFT media url to 
    //mitigate mapping back to original owner address
    string private __baseURI;

    mapping(uint256 tokenId => address) private _owners;

    mapping(address owner => uint256) private _balances;

    mapping(uint256 tokenId => address) private _tokenApprovals;

    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

    modifier onlyIssuer() {
        require(issuer != address(0), "NonTransferableERC721: not initialized");
        _;
    }


    modifier notUpgraded() {
        require(!upgraded, "NonTransferableERC721: contract has been upgraded");
        _;
    }

    event ERC721Minted(address indexed to, uint256 tokenId);
    event ERC721Upgraded(address indexed oldAsset, address indexed newAsset);
    event ERC721HookAdded(address indexed hook);
    event ERC721HookRemoved(address indexed hook);


    //called once when master-copy deployed
    constructor(address factory, address registry, address _avatarRegistry, address _experienceRegistry) {
        require(factory != address(0), "NonTransferableERC721: factory is the zero address");
        require(registry != address(0), "NonTransferableERC721: registry is the zero address");
        require(_avatarRegistry != address(0), "NonTransferableERC721: avatarRegistry is the zero address");
        require(_experienceRegistry != address(0), "NonTransferableERC721: experienceRegistry is the zero address");
        assetFactory = factory;
        assetRegistry = registry;
        avatarRegistry = IAvatarRegistry(_avatarRegistry);
        experienceRegistry = IExperienceRegistry(_experienceRegistry);
    }

    function encodeInitData(ERC721InitData memory data) public pure returns (bytes memory) {
        return abi.encode(data);
    }

    function init(bytes memory initData) public onlyFactory {
        ERC721InitData memory data = abi.decode(initData, (ERC721InitData));
        require(data.issuer != address(0), "NonTransferableERC721: issuer is the zero address");
        require(bytes(data.name).length > 0, "NonTransferableERC721: name is empty");
        require(bytes(data.symbol).length > 0, "NonTransferableERC721: symbol is empty");
        require(bytes(data.baseURI).length > 0, "NonTransferableERC721: baseURI is empty");
        require(data.originChainAddress != address(0), "NonTransferableERC721: originChainAddress is the zero address");
        require(data.originChainId > 0, "NonTransferableERC721: originChainId is zero");
        issuer = data.issuer;
        originAddress = data.originChainAddress;
        originChainId = data.originChainId;
        _name = data.name;
        _symbol = data.symbol;
        __baseURI = data.baseURI;
    }

    function upgrade(address newAsset) public onlyRegistry() {
        require(newAsset != address(this), "NonTransferableERC721Asset: new upgrade contract address cannot match original");
        
        //NOTE: be sure new contract implements this interface!
        IUpgradedERC721(newAsset).setStartingTokenId(_tokenIdCounter);
        upgraded = true;
        emit ERC721Upgraded(address(this), newAsset);
    }

    function addHook(IAssetHook _hook) public onlyIssuer {
        require(address(hook) != address(0), "NonTransferableERC721Asset: hook cannot be zero address");
        hook = _hook;
        emit ERC721HookAdded(address(_hook));
    }

    function removeHook() public onlyIssuer {
        address h = address(hook);
        emit ERC721HookRemoved(h);
        delete hook;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
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
            revert ERC721InvalidOwner(address(0));
        }
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return __baseURI;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address, uint256) public virtual {
        revert("NonTransferableERC721: token is non-transferable");
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address, bool) public virtual {
        revert("NonTransferableERC721: token is non-transferable");
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address, address, uint256) public virtual {
        revert("NonTransferableERC721: token is non-transferable");
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
        revert("NonTransferableERC721: token is non-transferable");
    }

    function mint(address to) public onlyIssuer() returns (uint256 id)  {
        //FIXME: if the to address is an Avatar (check with avatar registry once 
        //launched), need to ask the avatar if it allows tokens to minted 
        //outside of its active experience.
        if(address(hook) != address(0)) {
            bool s = hook.beforeMint(address(this), to, _tokenIdCounter+1);
            if(!s) {
                revert("NonTransferableERC721Asset: beforeMint hook rejected request");
            }
        }
        if(avatarRegistry.isAvatar(to)) {
            IAvatar avatar = IAvatar(to);
            if(!avatar.canReceiveTokensOutsideOfExperience()) {
                _verifyAvatarLocationMatchesIssuer(IAvatar(to));
            }
        }

        ++_tokenIdCounter;
        id = _tokenIdCounter;
        _safeMint(to, id);
    }

    function revoke(address tgt, uint256 tokenId) public onlyIssuer {
        if(address(hook) != address(0)) {
            bool s = hook.beforeRevoke(address(this), tgt, tokenId);
            if(!s) {
                revert("NonTransferableERC721Asset: beforeMint hook rejected request");
            }
        }
        _burn(tokenId);
    }


    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns (bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
     * the `spender` for the specific `tokenId`.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view virtual {
        if (!_isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0)) {
                revert ERC721NonexistentToken(tokenId);
            } else {
                revert ERC721InsufficientApproval(spender, tokenId);
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
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
    function _mint(address to, uint256 tokenId) internal notUpgraded() {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _update(to, tokenId, address(0));
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
        emit ERC721Minted(to, tokenId);
    }

    function _verifyAvatarLocationMatchesIssuer(IAvatar avatar) internal view {
        //get the avatar's current location
        VectorAddress memory va = avatar.location();
        IExperience exp = experienceRegistry.getExperienceByVector(va);
        require(exp.company() == issuer, "NonTransferableERC721Asset: avatar does not receive tokens outside of its current experience");
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
        address previousOwner = _update(address(0), tokenId, address(0));
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }



    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return owner;
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
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }


    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        // Avoid reading the owner unless necessary
        if (emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (auth != address(0) && owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }




}
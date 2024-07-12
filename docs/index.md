# Solidity API

## AssetCheckArgs

```solidity
struct AssetCheckArgs {
  address asset;
  address world;
  address company;
  address experience;
  address avatar;
}
```

## IAssetCondition

_This interface should be implemented to customize the conditional behavior of 
viewing or using an asset in the interoperability layer. Companies can deploy custom
conditions and add them to their controlled assets.

There are some situations where assets may or may not be viewable or usable in 
a metaverse environment. Licensing, restrictions, or other conditions may have to be 
met before the asset is allowed. This condition can be added to any asset by its issuing
company to enforce rules. Note, however, that the only time these rules are enforced
on-chain is when an Avatar attempt to add a wearable to itself. All other checks are
likely to happen off-chain or within other metaverse smart contracts interacting with
avatars and their assets._

### canView

```solidity
function canView(struct AssetCheckArgs args) external view returns (bool)
```

_Returns true if the asset can be viewed by the given world, company, experience, and avatar._

### canUse

```solidity
function canUse(struct AssetCheckArgs args) external view returns (bool)
```

_Returns true if the asset can be used by the given world, company, experience, and avatar._

## IMultiAssetRegistry

_To simplify asset verification regardless of its type, this interface wraps
multiple asset registries into a single interface. This allows for a single call 
to check all registries for a valid assets._

### isRegistered

```solidity
function isRegistered(address asset) external view returns (bool)
```

_Returns true if the asset is registered in any of the registries_

### registerRegistry

```solidity
function registerRegistry(contract IAssetRegistry registry) external
```

_Registers a new asset with the registry. Only callable by the registry admin_

## MultiAssetRegistryConstructorArgs

```solidity
struct MultiAssetRegistryConstructorArgs {
  address mainAdmin;
  address[] admins;
  contract IAssetRegistry[] registries;
}
```

## MultiAssetRegistry

### ADMIN_ROLE

```solidity
bytes32 ADMIN_ROLE
```

### registries

```solidity
contract IAssetRegistry[] registries
```

### onlyAdmin

```solidity
modifier onlyAdmin()
```

### constructor

```solidity
constructor(struct MultiAssetRegistryConstructorArgs args) public
```

### isRegistered

```solidity
function isRegistered(address asset) external view returns (bool)
```

_Returns true if the asset is registered in any of the registries_

### registerRegistry

```solidity
function registerRegistry(contract IAssetRegistry registry) external
```

_Registers a new asset with the registry. Only callable by the registry admin_

## BaseAssetConstructorArgs

Constructor arguments that immutably reference registries and factories required
for asset management.

```solidity
struct BaseAssetConstructorArgs {
  address assetRegistry;
  address avatarRegistry;
  address companyRegistry;
}
```

## BaseInitArgs

Once an asset proxy is cloned, its underlying implementation is initialized. These are the 
base asset init args to initialize basic/common asset information

```solidity
struct BaseInitArgs {
  string name;
  string symbol;
  address issuer;
  address originAddress;
  uint256 originChainId;
}
```

## BaseAsset

_BaseAsset is the base contract for all assets. It provides the basic
functionality for asset management, including the ability to add and remove
hooks and conditions, as well as the ability to verify that an asset can be
viewed or used by a given avatar._

### assetRegistry

```solidity
address assetRegistry
```

Fields initialized by asset master-copy constructor

### avatarRegistry

```solidity
contract IAvatarRegistry avatarRegistry
```

### companyRegistry

```solidity
contract ICompanyRegistry companyRegistry
```

### onlyIssuer

```solidity
modifier onlyIssuer()
```

### constructor

```solidity
constructor(struct BaseAssetConstructorArgs args) internal
```

Called once at deploy time. All cloned instances of this asset will retain immutable
references to the registries and factories required for asset management.

### initBase

```solidity
function initBase(struct BaseInitArgs args) internal
```

_Initializes basic asset information_

### owningRegistry

```solidity
function owningRegistry() internal view returns (address)
```

_Returns the address of the registry that manages this asset._

### symbol

```solidity
function symbol() public view returns (string)
```

_Returns the symbol of the token, usually a shorter version of the
name._

### issuer

```solidity
function issuer() public view returns (address)
```

_Returns the address of the issuer (company) of the asset._

### originAddress

```solidity
function originAddress() public view returns (address)
```

_Returns the address of the origin chain where the asset was created._

### originChainId

```solidity
function originChainId() public view returns (uint256)
```

_Returns the chain id of the origin chain where the asset was created._

### setCondition

```solidity
function setCondition(address condition) public
```

_sets a condition on the asset for viewing and / or using. Only the issuer can
call this function._

### removeCondition

```solidity
function removeCondition() public
```

_removes the condition on the asset for viewing and / or using. Only the issuer can
call this function._

### canViewAsset

```solidity
function canViewAsset(struct AssetCheckArgs args) public view returns (bool)
```

_Checks if the asset can be viewed based on the world/company/experience/avatar_

### canUseAsset

```solidity
function canUseAsset(struct AssetCheckArgs args) public view returns (bool)
```

_Checks if the asset can be used based on the world/company/experience/avatar_

### _verifyAvatarLocationMatchesIssuer

```solidity
function _verifyAvatarLocationMatchesIssuer(contract IAvatar avatar) internal view
```

_Verifies that the issuer of this asset also ows the experience for the avatar. 
This prevents airdropping tokens when not wanted by the avatar._

### _verifyAvatarMinting

```solidity
function _verifyAvatarMinting(address to) internal view
```

## AssetInitArgs

_Basic initialization arguments for an asset_

```solidity
struct AssetInitArgs {
  string name;
  string symbol;
  address issuer;
  address originAddress;
  uint256 originChainId;
  bytes initData;
}
```

## IAsset

_IAsset is the base interface for all assets. It provides the basic
functionality for asset management, including the ability to add and remove
conditions, as well as the ability to verify that an asset can be viewed or 
used._

### AssetConditionSet

```solidity
event AssetConditionSet(address condition)
```

### AssetConditionRemoved

```solidity
event AssetConditionRemoved()
```

### init

```solidity
function init(struct AssetInitArgs args) external
```

_Initializes the asset with the given arguments. This method is called
only once when the asset is cloned._

### symbol

```solidity
function symbol() external view returns (string)
```

_Returns the symbol of the token, usually a shorter version of the
name._

### issuer

```solidity
function issuer() external view returns (address)
```

_Returns the issuer (company) allowed to mint/burn the asset._

### originAddress

```solidity
function originAddress() external view returns (address)
```

_Returns the address of the asset on the origin chain._

### originChainId

```solidity
function originChainId() external view returns (uint256)
```

_Returns the chain id of the origin chain._

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```

_Returns the balance of assets for the given holder_

### approve

```solidity
function approve(address, uint256) external returns (bool)
```

_Approves spending asset for given spender_

### transferFrom

```solidity
function transferFrom(address, address, uint256) external returns (bool)
```

_Transfers asset from sender to given recipient_

### setCondition

```solidity
function setCondition(address condition) external
```

_sets a condition on the asset for viewing/using_

### removeCondition

```solidity
function removeCondition() external
```

_removes the condition on the asset for viewing/using_

### canViewAsset

```solidity
function canViewAsset(struct AssetCheckArgs args) external view returns (bool)
```

_Checks if the asset can be viewed based on the world/company/experience/avatar_

### canUseAsset

```solidity
function canUseAsset(struct AssetCheckArgs args) external view returns (bool)
```

_Checks if the asset can be used based on the world/company/experience/avatar_

## IERC20Asset

_IERC20Asset represents a synthetic asset for any XR chain ERC20 tokens._

### ERC20Minted

```solidity
event ERC20Minted(address to, uint256 amt)
```

### canMint

```solidity
function canMint(address to, uint256 amt) external view returns (bool)
```

_Returns true if the asset can be minted to the given address with the given data_

### mint

```solidity
function mint(address to, uint256 amt) external
```

_Mints the asset to the given address with the given data. Only callable by the asset issuer
after verifying the minting parameters._

### revoke

```solidity
function revoke(address holder, uint256 amt) external
```

_Revokes the asset from the given address with the given data. Only callable by the asset issuer_

### decimals

```solidity
function decimals() external view returns (uint8)
```

_Returns the number of decimals for the asset (preferably aligned with original ERC20)_

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

_Returns the total supply of the asset (this only represents the XR chain supply,
not the original ERC20 supply)_

### allowance

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```

_Returns the any spend allowance for the spender on the owner's asset_

### transfer

```solidity
function transfer(address, uint256) external returns (bool)
```

_Transfers the asset to the recipient_

## ERC20InitData

```solidity
struct ERC20InitData {
  uint8 decimals;
  uint256 maxSupply;
}
```

## NTERC20Asset

_NTERC20Asset represents a synthetic asset for any XR chain ERC20 tokens._

### constructor

```solidity
constructor(struct BaseAssetConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the entity._

### init

```solidity
function init(struct AssetInitArgs args) external
```

_Initialize the state for the ERC20 asset. NOTE: this is called on the asset's proxy and 
falls back to this version of the asset implementation. This is called when a new asset is 
created in the ERC20 registry and its proxy is cloned. This implementation is set on the proxy
and the init method is called in the context of the proxy (i.e. using proxy's storage)._

### decimals

```solidity
function decimals() external view returns (uint8)
```

_Returns the number of decimals for the asset (preferably aligned with original ERC20)_

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

_Returns the total supply of the asset (this only represents the XR chain supply,
not the original ERC20 supply)_

### balanceOf

```solidity
function balanceOf(address account) public view virtual returns (uint256)
```

_See {IERC20-balanceOf}._

### allowance

```solidity
function allowance(address owner, address spender) public view virtual returns (uint256)
```

_See {IERC20-allowance}._

### canMint

```solidity
function canMint(address to, uint256 amt) public view returns (bool)
```

_Returns true if the asset can be minted to the given address with the given data_

### mint

```solidity
function mint(address to, uint256 amt) public
```

_Mints the asset to the given address with the given data. Only callable by the asset issuer
after verifying the minting parameters._

### revoke

```solidity
function revoke(address tgt, uint256 amt) public
```

_Revokes the asset from the given address with the given data. Only callable by the asset issuer_

### transfer

```solidity
function transfer(address, uint256) public pure returns (bool)
```

_Transfers the asset to the recipient_

### approve

```solidity
function approve(address, uint256) public pure returns (bool)
```

_See {IERC20-approve}.

NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
`transferFrom`. This is semantically equivalent to an infinite approval.

Requirements:

- `spender` cannot be the zero address._

### transferFrom

```solidity
function transferFrom(address, address, uint256) public pure returns (bool)
```

_See {IERC20-transferFrom}.

Emits an {Approval} event indicating the updated allowance. This is not
required by the EIP. See the note at the beginning of {ERC20}.

NOTE: Does not update the allowance if the current allowance
is the maximum `uint256`.

Requirements:

- `from` and `to` cannot be the zero address.
- `from` must have a balance of at least `value`.
- the caller must have allowance for ``from``'s tokens of at least
`value`._

### _update

```solidity
function _update(address from, address to, uint256 value) internal virtual
```

_Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
(or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
this function.

Emits a {Transfer} event._

### _mint

```solidity
function _mint(address account, uint256 value) internal
```

_Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
Relies on the `_update` mechanism

Emits a {Transfer} event with `from` set to the zero address.

NOTE: This function is not virtual, {_update} should be overridden instead._

### _burn

```solidity
function _burn(address account, uint256 value) internal
```

_Destroys a `value` amount of tokens from `account`, lowering the total supply.
Relies on the `_update` mechanism.

Emits a {Transfer} event with `to` set to the zero address.

NOTE: This function is not virtual, {_update} should be overridden instead_

## ERC20AssetProxy

_Proxy for erc20 asset implementation to allow for future logic upgrades._

### constructor

```solidity
constructor(address reg) public
```

## ERC721AssetProxy

_Proxy for erc721 asset implementation to allow for future logic upgrades._

### constructor

```solidity
constructor(address registry) public
```

## IERC721Asset

_IERC721Asset represents a synthetic asset for any XR chain ERC721 tokens._

### Transfer

```solidity
event Transfer(address from, address to, uint256 tokenId)
```

_Emitted when `tokenId` token is transferred from `from` to `to`._

### Approval

```solidity
event Approval(address owner, address approved, uint256 tokenId)
```

_Emitted when `owner` enables `approved` to manage the `tokenId` token._

### BaseURIChanged

```solidity
event BaseURIChanged(string baseURI)
```

### ERC721Minted

```solidity
event ERC721Minted(address to, uint256 tokenId)
```

### canMint

```solidity
function canMint(address to) external view returns (bool)
```

_Returns true if the asset can be minted to the given address with the given data_

### mint

```solidity
function mint(address to) external
```

_Mints the asset to the given address with the given data. Only callable by the asset issuer
after verifying the minting parameters._

### revoke

```solidity
function revoke(address holder, uint256 tokenId) external
```

_Revokes the asset from the given address with the given data. Only callable by the asset issuer_

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```

_returns whether given selector is supported by this contract_

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```

_Returns owner of given token id_

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```

_Returns the uri used to retrieve token metadata_

### setBaseURI

```solidity
function setBaseURI(string baseURI) external
```

_Sets the base URI for all token ids_

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```

_Gets address approved to manage the given token ID_

### setApprovalForAll

```solidity
function setApprovalForAll(address, bool) external
```

_Set approval for a given address on all token ids_

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```

_Check if given address is approved for all token ids_

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external
```

_Safely transfer tokens from holder to new address. This requires approval from holder
and the receiver must implement ERC721Receiver interface_

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) external
```

_Safely transfer tokens from holder to new address. This requires approval from holder
and the receiver must implement ERC721Receiver interface_

## ERC721InitData

```solidity
struct ERC721InitData {
  string baseURI;
}
```

## NTERC721Asset

_NTERC721Asset represents a synthetic asset for any XR chain ERC721 tokens._

### constructor

```solidity
constructor(struct BaseAssetConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the entity._

### init

```solidity
function init(struct AssetInitArgs args) external
```

_Initialize the state for the ERC721 asset. NOTE: this is called on the asset's proxy and 
falls back to this version of the asset implementation. This is called when a new asset is 
created in the ERC721 registry and its proxy is cloned. This implementation is set on the proxy
and the init method is called in the context of the proxy (i.e. using proxy's storage)._

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

_returns whether given selector is supported by this contract_

### balanceOf

```solidity
function balanceOf(address owner) public view virtual returns (uint256)
```

_See {IERC721-balanceOf}._

### ownerOf

```solidity
function ownerOf(uint256 tokenId) public view virtual returns (address)
```

_See {IERC721-ownerOf}._

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view virtual returns (string)
```

_See {IERC721Metadata-tokenURI}._

### _baseURI

```solidity
function _baseURI() internal view virtual returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

### setBaseURI

```solidity
function setBaseURI(string uri) public
```

_Set the base URI for all token IDs. Can only be called by a_

### canMint

```solidity
function canMint(address to) public view returns (bool)
```

_determine if the asset can be minted_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | the address to mint to data is not used in minting so it is ignored |

### mint

```solidity
function mint(address to) public
```

_Mints NFT to the specified address. This can only be called by the issuer_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | the address to mint tokens to |

### revoke

```solidity
function revoke(address holder, uint256 tokenId) public
```

_Revokes NFT from the specified address. This can only be called by the issuer_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| holder | address | the address to revoke NFT from |
| tokenId | uint256 |  |

### approve

```solidity
function approve(address, uint256) public pure returns (bool)
```

_Approves spending asset for given spender_

### getApproved

```solidity
function getApproved(uint256 tokenId) public view virtual returns (address)
```

_See {IERC721-getApproved}._

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) public view virtual returns (bool)
```

_Check if given address is approved for all token ids_

### setApprovalForAll

```solidity
function setApprovalForAll(address, bool) public virtual
```

_See {IERC721-setApprovalForAll}._

### transferFrom

```solidity
function transferFrom(address, address, uint256) public pure returns (bool)
```

_See {IERC721-transferFrom}._

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) public
```

_See {IERC721-safeTransferFrom}._

### safeTransferFrom

```solidity
function safeTransferFrom(address, address, uint256, bytes) public virtual
```

_See {IERC721-safeTransferFrom}._

### _mint

```solidity
function _mint(address to, uint256 tokenId) internal
```

_Mints `tokenId` and transfers it to `to`.

WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible

Requirements:

- `tokenId` must not exist.
- `to` cannot be the zero address.

Emits a {Transfer} event._

### _safeMint

```solidity
function _safeMint(address to, uint256 tokenId) internal
```

_Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.

Requirements:

- `tokenId` must not exist.
- If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.

Emits a {Transfer} event._

### _safeMint

```solidity
function _safeMint(address to, uint256 tokenId, bytes data) internal virtual
```

_Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
forwarded in {IERC721Receiver-onERC721Received} to contract recipients._

### _burn

```solidity
function _burn(uint256 tokenId) internal
```

_Destroys `tokenId`.
The approval is cleared when the token is burned.
This is an internal function that does not check if the sender is authorized to operate on the token.

Requirements:

- `tokenId` must exist.

Emits a {Transfer} event._

### _endsWith

```solidity
function _endsWith(string str, string suffix) internal pure returns (bool)
```

## BaseAssetRegistry

_BaseAssetRegistry is the base contract for all asset registries. It provides the basic
functionality for asset management, including the ability to register and remove assets._

### assetExists

```solidity
function assetExists(address original, uint256 chainId) public view returns (bool)
```

_Determines if an asset from an original chain has been registered_

### registerAsset

```solidity
function registerAsset(struct CreateAssetArgs args) public returns (address asset)
```

_Registers a new asset with the registry. Only callable by the registry admin
after verifying ownership by the issuing company._

### deactivateAsset

```solidity
function deactivateAsset(address asset, string reason) public
```

_Deactivates an asset in the registry. Only callable by the registry admin_

### reactivateAsset

```solidity
function reactivateAsset(address asset) public
```

_Reactivates an asset in the registry. Only callable by the registry admin_

### removeAsset

```solidity
function removeAsset(address asset, string reason) public
```

_Removes an asset from the registry. Only callable by the registry admin AFTER
the grace period has expired._

## ERC20Registry

_ERC20Registry is the registry for all ERC20 asset types. It provides the basic
functionality for ERC20 asset management, including the ability to register and remove ERC20 assets._

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

## ERC20RegistryProxy

_ERC20RegistryProxy is the proxy contract for the ERC20Registry. It allows the registry logic 
to be upgraded without changing the address of the registry or its storage._

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) public
```

## ERC721Registry

_ERC721Registry is the registry contract for ERC721 assets. It provides the basic
functionality for ERC721 asset management, including the ability to register and remove assets._

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

## ERC721RegistryProxy

_ERC721RegistryProxy is the proxy contract for the ERC721Registry. It allows the registry logic 
to be upgraded without changing the address of the registry or its storage._

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) public
```

## CreateAssetArgs

_Common asset creation arguments. Used by the registry to create new assets._

```solidity
struct CreateAssetArgs {
  address issuer;
  address originAddress;
  uint256 originChainId;
  string name;
  string symbol;
  bytes initData;
}
```

## IAssetRegistry

### assetExists

```solidity
function assetExists(address original, uint256 chainId) external view returns (bool)
```

_Determines if the asset from the original chain has been registered_

### registerAsset

```solidity
function registerAsset(struct CreateAssetArgs args) external returns (address asset)
```

_Registers a new asset with the registry. Only callable by the registry admin
after verifying ownership by the issuing company._

### deactivateAsset

```solidity
function deactivateAsset(address asset, string reason) external
```

_Deactivates an asset. Only callable by the registry admin_

### reactivateAsset

```solidity
function reactivateAsset(address asset) external
```

_Reactivates an asset. Only callable by the registry admin_

### removeAsset

```solidity
function removeAsset(address asset, string reason) external
```

_Removes an asset from the registry. Only callable by the registry admin
after the registration grace period has expired_

## AssetRegistryStorage

```solidity
struct AssetRegistryStorage {
  mapping(bytes32 => address) assetsByOriginChain;
}
```

## LibAssetRegistry

_The asset registry library provides functions to get storage for any asset registry type._

### load

```solidity
function load() internal pure returns (struct AssetRegistryStorage store)
```

### assetExists

```solidity
function assetExists(address original, uint256 chainId) internal view returns (bool)
```

_Checks if an asset has been registered based on its origin chain info._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| original | address | The original asset address. |
| chainId | uint256 | The chain ID. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | True if the asset has been registered, false otherwise. |

### markAssetExists

```solidity
function markAssetExists(address original, uint256 chainId, address asset) internal
```

_Marks an asset as registered based on its origin chain info._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| original | address | The original asset address. |
| chainId | uint256 | The chain ID. |
| asset | address | The asset address. |

## AvatarInitData

_avatar initialization arguments. This is the extra bytes of an avatar creation request._

```solidity
struct AvatarInitData {
  bool canReceiveTokensOutsideExperience;
  bytes appearanceDetails;
}
```

## AvatarConstructorArgs

_Avatar constructor arguments. These are mapped to immutable regitry addresses so that any
clone of the avatar can access the same registry contracts._

```solidity
struct AvatarConstructorArgs {
  address avatarRegistry;
  address companyRegistry;
  address experienceRegistry;
  address portalRegistry;
  address erc721Registry;
}
```

## Avatar

_Avatar provides the basic functionality for avatar management, including the 
ability to add and remove wearables, as well as the ability to jump between experiences.
Avatar contracts hold assets and can be used to represent a user in a virtual world._

### avatarRegistry

```solidity
address avatarRegistry
```

### experienceRegistry

```solidity
contract IExperienceRegistry experienceRegistry
```

### companyRegistry

```solidity
contract ICompanyRegistry companyRegistry
```

### erc721Registry

```solidity
contract IAssetRegistry erc721Registry
```

### portalRegistry

```solidity
contract IPortalRegistry portalRegistry
```

### onlyActiveCompany

```solidity
modifier onlyActiveCompany()
```

### constructor

```solidity
constructor(struct AvatarConstructorArgs args) public
```

### version

```solidity
function version() public pure returns (struct Version)
```

_Returns the version of the entity._

### init

```solidity
function init(struct AvatarInitArgs args) public
```

_Initialize the avatar. This is called by the avatar registry when creating a new avatar.
It is invoked through its proxy so that any storage updates are done in the proxy's address space._

### owningRegistry

```solidity
function owningRegistry() internal view returns (address)
```

_Get the registry that owns this contract._

### username

```solidity
function username() public view returns (string)
```

_get the Avatar's unique username_

### location

```solidity
function location() public view returns (address)
```

_get the Avatar's current experience location_

### appearanceDetails

```solidity
function appearanceDetails() public view returns (bytes)
```

_get the Avatar's appearance details. These will be specific to the avatar
implementation off chain should be used by clients to render the avatar correctly._

### canReceiveTokensOutsideOfExperience

```solidity
function canReceiveTokensOutsideOfExperience() public view returns (bool)
```

_Check whether an avatar can receive tokens when not in an experience that 
matches their current location. This prevents spamming of tokens to the avatar._

### companySigningNonce

```solidity
function companySigningNonce(address signer) public view returns (uint256)
```

_Get the next signing nonce for a company signature._

### avatarOwnerSigningNonce

```solidity
function avatarOwnerSigningNonce() public view returns (uint256)
```

_Get the next signing nonce for an avatar owner signature._

### getWearables

```solidity
function getWearables() public view returns (struct Wearable[])
```

_Get the list of wearables the avatar is currently wearing._

### isWearing

```solidity
function isWearing(struct Wearable wearable) public view returns (bool)
```

_Check if the avatar is wearing a specific wearable asset._

### canAddWearable

```solidity
function canAddWearable(struct Wearable wearable) public view returns (bool)
```

_Check if the avatar can wear the given asset_

### addWearable

```solidity
function addWearable(struct Wearable wearable) public
```

_Add a wearable asset to the avatar. This must be called by the avatar owner. 
This will revert if there are already 200 wearables configured._

### removeWearable

```solidity
function removeWearable(struct Wearable wearable) public
```

_Remove a wearable asset from the avatar. This must be called by the avatar owner._

### setCanReceiveTokensOutsideOfExperience

```solidity
function setCanReceiveTokensOutsideOfExperience(bool canReceive) public
```

_Set whether the avatar can receive tokens when not in an experience that matches 
their current location._

### setAppearanceDetails

```solidity
function setAppearanceDetails(bytes details) public
```

_Set the appearance details of the avatar. This must be called by the avatar owner._

### jump

```solidity
function jump(struct AvatarJumpRequest request) public payable
```

_Move the avatar to a new experience. This must be called by the avatar owner.
If fees are required for the jump, they must be attached to the transaction or come
from the avatar contract balance._

### delegateJump

```solidity
function delegateJump(struct DelegatedJumpRequest request) public payable
```

_Company can pay for the avatar jump txn. This must be 
called by a registered company contract. The avatar owner must sign off on
the request using the owner nonce tracked by this contract. If fees are required
for the jump, they must be attached to the transaction or come from the avatar
contract balance. The avatar owner signature approves the transfer of funds if 
coming from avatar contract._

### withdraw

```solidity
function withdraw(uint256 amount) public
```

_Withdraw funds from the avatar contract. This must be called by the avatar owner._

### onERC721Received

```solidity
function onERC721Received(address, address, uint256 tokenId, bytes) public returns (bytes4)
```

_Receive ERC721 tokens sent to the avatar. This must be called by a registered
erc721 asset contract. If the avatar does not allow mints outside of its current
experience, the issuer for the calling asset must match the current experience's company._

### onERC721Revoked

```solidity
function onERC721Revoked(uint256 tokenId) public
```

_Revoke ERC721 tokens sent to the avatar. This must be called by a registered
erc721 asset contract._

### _verifyCompanySignature

```solidity
function _verifyCompanySignature(struct AvatarJumpRequest request) internal returns (struct PortalInfo portal)
```

### _verifyAvatarSignature

```solidity
function _verifyAvatarSignature(struct DelegatedJumpRequest request) internal
```

## AvatarProxy

_A proxy contract for Avatar that allows to delegate calls to the Avatar contract while
preserving avatar address and storage._

### constructor

```solidity
constructor(address reg) public
```

## AvatarJumpRequest

_Arguments for an avatar jump._

```solidity
struct AvatarJumpRequest {
  uint256 portalId;
  uint256 agreedFee;
  bytes destinationCompanySignature;
}
```

## DelegatedJumpRequest

_Arguments for a delegated jump (i.e. company paying for txn)_

```solidity
struct DelegatedJumpRequest {
  uint256 portalId;
  uint256 agreedFee;
  bytes avatarOwnerSignature;
}
```

## AvatarInitArgs

```solidity
struct AvatarInitArgs {
  string name;
  address owner;
  address startingExperience;
  bytes initData;
}
```

## IAvatar

_The Avatar interface._

### WearableAdded

```solidity
event WearableAdded(address wearable, uint256 tokenId)
```

### WearableRemoved

```solidity
event WearableRemoved(address wearable, uint256 tokenId)
```

### LocationChanged

```solidity
event LocationChanged(address location)
```

### AppearanceChanged

```solidity
event AppearanceChanged(bytes appearanceDetails)
```

### JumpSuccess

```solidity
event JumpSuccess(address experience, uint256 fee, bytes connectionDetails)
```

### init

```solidity
function init(struct AvatarInitArgs args) external
```

_Initialize the Avatar with the given parameters. This function should only be called once
after cloning a new avatar._

### username

```solidity
function username() external view returns (string)
```

_get the Avatar's unique username_

### location

```solidity
function location() external view returns (address)
```

_get the Avatar's current experience location_

### appearanceDetails

```solidity
function appearanceDetails() external view returns (bytes)
```

_get the Avatar's appearance details. These will be specific to the avatar
implementation off chain should be used by clients to render the avatar correctly._

### canReceiveTokensOutsideOfExperience

```solidity
function canReceiveTokensOutsideOfExperience() external view returns (bool)
```

_Check whether an avatar can receive tokens when not in an experience that 
matches their current location. This prevents spamming of tokens to the avatar._

### companySigningNonce

```solidity
function companySigningNonce(address signer) external view returns (uint256)
```

_Get the next signing nonce for a company signature._

### avatarOwnerSigningNonce

```solidity
function avatarOwnerSigningNonce() external view returns (uint256)
```

_Get the next signing nonce for an avatar owner signature._

### canAddWearable

```solidity
function canAddWearable(struct Wearable wearable) external view returns (bool)
```

_Determine if the given wearable can be used by the avatar._

### addWearable

```solidity
function addWearable(struct Wearable wearable) external
```

_Add a new wearable to the avatar. This must be called by the avatar owner._

### removeWearable

```solidity
function removeWearable(struct Wearable wearable) external
```

_Remove a wearable from the avatar. This must be called by the avatar owner._

### getWearables

```solidity
function getWearables() external view returns (struct Wearable[])
```

_Get the wearables currently worn by the avatar._

### isWearing

```solidity
function isWearing(struct Wearable wearable) external view returns (bool)
```

_Check if the avatar is wearing a specific wearable._

### setCanReceiveTokensOutsideOfExperience

```solidity
function setCanReceiveTokensOutsideOfExperience(bool canReceive) external
```

_Set whether the avatar can receive tokens when not in an experience that matches 
their current location._

### setAppearanceDetails

```solidity
function setAppearanceDetails(bytes) external
```

_Set the appearance details of the avatar. This must be called by the avatar owner._

### jump

```solidity
function jump(struct AvatarJumpRequest request) external payable
```

_Move the avatar to a new experience. This must be called by the avatar owner.
If fees are required for the jump, they must be attached to the transaction or come
from the avatar contract balance._

### delegateJump

```solidity
function delegateJump(struct DelegatedJumpRequest request) external payable
```

_Company can pay for the avatar jump txn. This must be 
called by a registered company contract. The avatar owner must sign off on
the request using the owner nonce tracked by this contract. If fees are required
for the jump, they must be attached to the transaction or come from the avatar
contract balance. The avatar owner signature approves the transfer of funds if 
coming from avatar contract._

### withdraw

```solidity
function withdraw(uint256 amount) external
```

_Withdraw funds from the avatar contract. This must be called by the avatar owner._

### onERC721Revoked

```solidity
function onERC721Revoked(uint256 tokenId) external
```

_called when IERC721 asset is revoked._

## AvatarRegistryConstructorArgs

_Arguments for the AvatarRegistry constructor_

```solidity
struct AvatarRegistryConstructorArgs {
  address worldRegistry;
}
```

## AvatarRegistry

_A registry for Avatar entities_

### worldRegistry

```solidity
contract IWorldRegistry worldRegistry
```

### onlyActiveWorld

```solidity
modifier onlyActiveWorld()
```

### onlySigner

```solidity
modifier onlySigner()
```

### constructor

```solidity
constructor(struct AvatarRegistryConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

### canUpOrDowngrade

```solidity
function canUpOrDowngrade() internal view
```

### createAvatar

```solidity
function createAvatar(struct CreateAvatarArgs args) external returns (address proxy)
```

_Create a new Avatar entity_

## AvatarRegistryProxy

_A proxy contract for AvatarRegistry so it can be upgraded and retain address and storage_

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) public
```

## CreateAvatarArgs

```solidity
struct CreateAvatarArgs {
  bool sendTokensToOwner;
  address startingExperience;
  address owner;
  string name;
  bytes initData;
}
```

## IAvatarRegistry

### createAvatar

```solidity
function createAvatar(struct CreateAvatarArgs args) external returns (address)
```

## BaseAccess

_Base contract for all contracts that require access control._

### onlyAdmin

```solidity
modifier onlyAdmin()
```

### onlyOwner

```solidity
modifier onlyOwner()
```

### hasRole

```solidity
function hasRole(bytes32 role, address account) public view returns (bool)
```

### grantRole

```solidity
function grantRole(bytes32 role, address account) public
```

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) public
```

### addSigners

```solidity
function addSigners(address[] signers) public
```

### removeSigners

```solidity
function removeSigners(address[] signers) public
```

### isSigner

```solidity
function isSigner(address account) public view returns (bool)
```

### isAdmin

```solidity
function isAdmin(address account) public view returns (bool)
```

### owner

```solidity
function owner() public view returns (address)
```

### changeOwner

```solidity
function changeOwner(address newOwner) public
```

### initAccess

```solidity
function initAccess(address o, address[] admins) internal
```

## IProvidesVersion

### version

```solidity
function version() external view returns (struct Version)
```

## ProxyStorage

storage for proxy

```solidity
struct ProxyStorage {
  address implementation;
  struct Version version;
}
```

## BaseProxyConstructorArgs

_constructor args for base proxy_

```solidity
struct BaseProxyConstructorArgs {
  address impl;
  address owner;
  address[] admins;
}
```

## BaseProxy

_Base proxy for all non-entity proxy contracts._

### onlyOwner

```solidity
modifier onlyOwner()
```

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) internal
```

### receive

```solidity
receive() external payable
```

### load

```solidity
function load() internal pure returns (struct ProxyStorage ps)
```

### setImplementation

```solidity
function setImplementation(address _implementation) external
```

_set the implementation contract to use for the proxy. Only the owner can change
the logic contract which ultimately changes the behavior of the contract. The storage
will remain in-tact but the logic will change. Note that all storage must be compatible
with newer and older versions of the logic contract. Older versions meaning if there is a 
rollback, the storage must remaining compatible with the older logic contract as well as any
new version._

### getImplementation

```solidity
function getImplementation() external view returns (address)
```

_get the implementation contract for the proxy_

### getVersion

```solidity
function getVersion() external view returns (struct Version)
```

_get the version of the implementation contract_

### fallback

```solidity
fallback() external payable
```

_fallback function to delegate execution to the implementation contract_

## BaseEntity

_Base contract for all (non-registry) entity types_

### onlyRegistry

```solidity
modifier onlyRegistry()
```

### onlySigner

```solidity
modifier onlySigner()
```

### receive

```solidity
receive() external payable
```

### owningRegistry

```solidity
function owningRegistry() internal view virtual returns (address)
```

_Returns the address of the registry that owns this entity_

### name

```solidity
function name() external view returns (string)
```

_Returns the name of the entity_

## BaseRemovableEntity

_Base contract for all removable entity types_

### termsOwner

```solidity
function termsOwner() public view returns (address)
```

_Get the authority that sets the permission to remove the entity_

### deactivate

```solidity
function deactivate(string reason) public virtual
```

_Deactivate the entity. This is only callable by the owning registry, which handles
authorization checks._

### reactivate

```solidity
function reactivate() public virtual
```

_Reactivate the entity. This is only callable by the owning registry, which handles
authorization checks._

### remove

```solidity
function remove(string reason) public virtual
```

_Remove the entity. This is only callable by the owning registry, which handles
authorization checks._

### isEntityActive

```solidity
function isEntityActive() public view returns (bool)
```

_Check whether the entity is active_

### isRemoved

```solidity
function isRemoved() public view returns (bool)
```

_Check whether the entity is removed_

## IProvidesVersion

### version

```solidity
function version() external view returns (struct Version)
```

## ProxyStorage

Storage for entity proxy

```solidity
struct ProxyStorage {
  address implementation;
  struct Version version;
}
```

## EntityProxy

_Base contract for all entity proxy types. Proxies are cloned as part of the registration
process. They are used to forward calls to the entity implementation contract._

### parentRegistry

```solidity
address parentRegistry
```

### onlyRegistry

```solidity
modifier onlyRegistry()
```

### receive

```solidity
receive() external payable
```

### constructor

```solidity
constructor(address registry) internal
```

### load

```solidity
function load() internal pure returns (struct ProxyStorage ps)
```

### setImplementation

```solidity
function setImplementation(address _implementation) external
```

_Set the implementation contract for the proxy. This is only callable by the registry
that clones the proxy. This is called just after cloning or during an entity upgrade._

### getImplementation

```solidity
function getImplementation() external view returns (address)
```

_Get the implementation contract for the proxy_

### getVersion

```solidity
function getVersion() external view returns (struct Version)
```

_Get the version of the implementation contract for the proxy_

### fallback

```solidity
fallback() external payable
```

_Fallback function that forwards all calls to the implementation contract_

## IEntityProxy

_Interface for entity proxy contracts_

### setImplementation

```solidity
function setImplementation(address _implementation) external
```

### getImplementation

```solidity
function getImplementation() external view returns (address)
```

### getVersion

```solidity
function getVersion() external view returns (struct Version)
```

## BaseRegistry

_Base contract for all registries._

### onlyRegisteredEntity

```solidity
modifier onlyRegisteredEntity()
```

### canUpOrDowngrade

```solidity
function canUpOrDowngrade() internal view virtual
```

### setEntityImplementation

```solidity
function setEntityImplementation(address _entityImplementation) public
```

_Set the entity implementation contract for the registry. All registries clone their entity
proxies and assign an entity implementation to that proxy._

### getEntityImplementation

```solidity
function getEntityImplementation() public view returns (address)
```

_Get the entity implementation contract for the registry._

### setProxyImplementation

```solidity
function setProxyImplementation(address _proxyImplementation) public
```

_Set the proxy implementation contract for the registry. All registries clone their entity
proxies. This is the base contract that is cloned._

### getProxyImplementation

```solidity
function getProxyImplementation() public view returns (address)
```

_Get the proxy implementation contract for the registry._

### getEntityVersion

```solidity
function getEntityVersion() public view returns (struct Version)
```

_Get the version for the entity logic contract. This can be used to detect if an 
upgrade is available._

### upgradeEntity

```solidity
function upgradeEntity() public virtual
```

_Entity owners can request to upgrade the underlying logic of their entity contract. This is 
done through the registry so that arbitrary logic cannot be attached to entity proxies to circumvent
protocol behaviors._

### downgradeEntity

```solidity
function downgradeEntity() public virtual
```

_Entity owners can request to downgrade the underlying logic of their entity contract. This is
done through the registry so that arbitrary logic cannot be attached to entity proxies to circumvent
protocol behaviors. This is useful for emergency situations where a bug is found in the latest logic._

### isRegistered

```solidity
function isRegistered(address addr) public view returns (bool)
```

_Check if an entity is registered in this registry._

### getEntityByName

```solidity
function getEntityByName(string name) public view returns (address)
```

_Get an entity by name._

### _registerNonRemovableEntity

```solidity
function _registerNonRemovableEntity(address entity) internal
```

_Register an entity in the registry._

## BaseRemovableRegistry

_Base contract for all registries that support entity removal._

### onlyEntityOwner

```solidity
modifier onlyEntityOwner(address entity)
```

### onlyActiveEntity

```solidity
modifier onlyActiveEntity()
```

### deactivateEntity

```solidity
function deactivateEntity(contract IRemovableEntity entity, string reason) external virtual
```

_Called by the entity's authority to deactivate the entity for the given reason._

### reactivateEntity

```solidity
function reactivateEntity(contract IRemovableEntity entity) external virtual
```

_Called by the entity's terms owner to reactivate the entity._

### removeEntity

```solidity
function removeEntity(contract IRemovableEntity entity, string reason) external virtual
```

_Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
the entity and waiting for the grace period to expire. A grace period must be set to given ample time
for the entity to respond to deactivation._

### getEntityTerms

```solidity
function getEntityTerms(address addr) public view returns (struct RegistrationTerms)
```

_Returns the terms for the given entity address_

### canBeDeactivated

```solidity
function canBeDeactivated(address addr) public view returns (bool)
```

_Returns whether an entity can be deactivated. Entities can only be deactivated
if they are either expired or within the grace period_

### canBeRemoved

```solidity
function canBeRemoved(address addr) public view returns (bool)
```

_Returns whether an entity can be removed. Entities can only be removed if they are
outside the grace period_

### enforceDeactivation

```solidity
function enforceDeactivation(contract IRemovableEntity addr) public
```

_Enforces deactivation of an entity. Can be called by anyone but will only
succeed if the entity is inside the grace period_

### enforceRemoval

```solidity
function enforceRemoval(contract IRemovableEntity e) public
```

_Enforces removal of an entity. Can be called by anyone but will only
succeed if it is outside the grace period_

### getLastRenewal

```solidity
function getLastRenewal(address addr) public view returns (uint256)
```

_Returns the last renewal timestamp in seconds for the given address._

### getExpiration

```solidity
function getExpiration(address addr) public view returns (uint256)
```

_Returns the expiration timestamp in seconds for the given address._

### isExpired

```solidity
function isExpired(address addr) public view returns (bool)
```

_Check whether an address is expired._

### isInGracePeriod

```solidity
function isInGracePeriod(address addr) public view returns (bool)
```

_Check whether an address is in the grace period._

### renewEntity

```solidity
function renewEntity(address addr) public payable
```

_Renew an entity by paying the renewal fee._

### changeEntityTerms

```solidity
function changeEntityTerms(struct ChangeEntityTermsArgs args) public virtual
```

_Change the terms for an entity. Can only be called by the entity's terms owner._

### canUpOrDowngrade

```solidity
function canUpOrDowngrade() internal view
```

_Upgrade the entity to the latest version of the registry. This overrides base registry version
to ensure entity is actually still active._

### _registerRemovableEntity

```solidity
function _registerRemovableEntity(address entity, address termsOwner, struct RegistrationTerms terms) internal
```

_Register an entity in the registry._

## BaseVectoredRegistry

_Base contract for all registries that support vector-based entity retrieval._

### getEntityByVector

```solidity
function getEntityByVector(struct VectorAddress vector) external view returns (address)
```

_Get the entity address for the given vector._

## CompanyConstructorArgs

```solidity
struct CompanyConstructorArgs {
  address companyRegistry;
  address experienceRegistry;
  address erc20Registry;
  address erc721Registry;
  address avatarRegistry;
}
```

## Company

_A company can issue assets and add experiences to worlds. This is the company logic 
implementation. All companies are fronted by an EntityProxy. The company constructor 
sets up immutable references to various registries for logic implementation._

### companyRegistry

```solidity
address companyRegistry
```

### experienceRegistry

```solidity
contract IExperienceRegistry experienceRegistry
```

### erc20Registry

```solidity
contract IAssetRegistry erc20Registry
```

### erc721Registry

```solidity
contract IAssetRegistry erc721Registry
```

### avatarRegistry

```solidity
contract IAvatarRegistry avatarRegistry
```

### onlyIfActive

```solidity
modifier onlyIfActive()
```

### constructor

```solidity
constructor(struct CompanyConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the entity._

### init

```solidity
function init(struct CompanyInitArgs args) public
```

_Initializes the company with the given information. This is called by the company registry
after cloning the company's proxy and assigning this logic to it._

### owningRegistry

```solidity
function owningRegistry() internal view returns (address)
```

_Returns the address of the company registry_

### world

```solidity
function world() public view returns (address)
```

_Returns the address of the world in which the company operates._

### vectorAddress

```solidity
function vectorAddress() public view returns (struct VectorAddress)
```

_Returns the vector address of the company. The vector address is assigned by
the operating World._

### canMintERC20

```solidity
function canMintERC20(address asset, address to, uint256 amount) public view returns (bool)
```

_Checks if this company can mint the given ERC20 asset. Only active companies can mint assets._

### canMintERC721

```solidity
function canMintERC721(address asset, address to) public view returns (bool)
```

_Checks if this company can mint the given ERC721 asset. Only active companies can mint assets._

### mintERC20

```solidity
function mintERC20(address asset, address to, uint256 amount) public
```

_Mints the given ERC20 asset to the given address. This can only be called by a company
signer and only if the company is active._

### mintERC721

```solidity
function mintERC721(address asset, address to) public
```

_Mints the given ERC721 asset to the given address. This can only be called by a company
signer and only if the company is active._

### revokeERC20

```solidity
function revokeERC20(address asset, address holder, uint256 amount) public
```

_Revokes the given ERC20 asset from the given address. This can only be called by a company
signer and only if the company is active._

### revokeERC721

```solidity
function revokeERC721(address asset, address holder, uint256 tokenId) public
```

_Revokes the given ERC721 asset from the given address. This can only be called by a company
signer and only if the company is active._

### setERC721BaseURI

```solidity
function setERC721BaseURI(address asset, string uri) public
```

_Sets the base URI for an ERC721 asset minted by this company. This can only be called by admins_

### addExperience

```solidity
function addExperience(struct AddExperienceArgs args) public returns (address experience, uint256 portalId)
```

_Adds an experience to the parent world. This also creates a portal into the 
experience and registers it in the PortalRegistry._

### deactivateExperience

```solidity
function deactivateExperience(address experience, string reason) public
```

_Deactivates an experience. This can only be called by company admin_

### reactivateExperience

```solidity
function reactivateExperience(address experience) public
```

_Reactivates an experience. This can only be called by company admin_

### removeExperience

```solidity
function removeExperience(address experience, string reason) public
```

_Removes an experience from the world. This also removes the portal into the 
experience and unregisters it from the PortalRegistry. This can only be called
by company admin_

### withdraw

```solidity
function withdraw(uint256 amount) public
```

_Withdraws the given amount of funds from the company. Only the owner can withdraw funds._

### addExperienceCondition

```solidity
function addExperienceCondition(address experience, address condition) public
```

_Adds an experience condition to an experience. Going through the company
contract provides the necessary authorization checks and that only the experience
owner can add conditions._

### removeExperienceCondition

```solidity
function removeExperienceCondition(address experience) public
```

_Removes an experience condition from an experience_

### changeExperiencePortalFee

```solidity
function changeExperiencePortalFee(address experience, uint256 fee) public
```

_Changes the fee associated with a portal to an experience owned by the company.
Going through the company provides appropriate authorization checks._

### addAssetCondition

```solidity
function addAssetCondition(address asset, address condition) public
```

_Adds an asset condition to an asset. Going through the company
contract provides the necessary authorization checks and that only the asset
issuer can add conditions._

### removeAssetCondition

```solidity
function removeAssetCondition(address asset) public
```

_Removes an asset condition from an asset_

### delegateJumpForAvatar

```solidity
function delegateJumpForAvatar(struct DelegatedAvatarJumpRequest request) public
```

_Delegates a jump for an avatar to the company. This allows the company to
pay the transaction fee but charge the avatar owner for the jump. This is useful
for companies that want to offer free jumps to avatars but charge them for the
experience._

## CompanyProxy

### constructor

```solidity
constructor(address reg) public
```

## AddExperienceArgs

_Arguments for companies to add an experience to a world._

```solidity
struct AddExperienceArgs {
  string name;
  bytes initData;
}
```

## DelegatedAvatarJumpRequest

_Arguments for delegating an avatar jump to a company._

```solidity
struct DelegatedAvatarJumpRequest {
  address avatar;
  uint256 portalId;
  uint256 agreedFee;
  bytes avatarOwnerSignature;
}
```

## CompanyInitArgs

```solidity
struct CompanyInitArgs {
  string name;
  address owner;
  address world;
  struct VectorAddress vector;
  bytes initData;
}
```

## ICompany

_Interface for a company that can add experiences to a world and mint assets.
Companies register through Worlds in order to offer experiences to avatars and 
create assets within worlds._

### CompanyAddedExperience

```solidity
event CompanyAddedExperience(address experience, uint256 portalId)
```

### CompanyDeactivatedExperience

```solidity
event CompanyDeactivatedExperience(address experience, string reason)
```

### CompanyReactivatedExperience

```solidity
event CompanyReactivatedExperience(address experience)
```

### CompanyRemovedExperience

```solidity
event CompanyRemovedExperience(address experience, string reason, uint256 portalId)
```

### CompanyAddedExperienceCondition

```solidity
event CompanyAddedExperienceCondition(address experience, address condition)
```

### CompanyRemovedExperienceCondition

```solidity
event CompanyRemovedExperienceCondition(address experience)
```

### CompanyChangedExperiencePortalFee

```solidity
event CompanyChangedExperiencePortalFee(address experience, uint256 fee)
```

### CompanyAddedAssetCondition

```solidity
event CompanyAddedAssetCondition(address asset, address condition)
```

### CompanyRemovedAssetCondition

```solidity
event CompanyRemovedAssetCondition(address asset)
```

### CompanyAddedAssetHook

```solidity
event CompanyAddedAssetHook(address asset, address hook)
```

### CompanyRemovedAssetHook

```solidity
event CompanyRemovedAssetHook(address asset)
```

### CompanyAddedExperienceHook

```solidity
event CompanyAddedExperienceHook(address experience, address hook)
```

### CompanyRemovedExperienceHook

```solidity
event CompanyRemovedExperienceHook(address experience)
```

### CompanyJumpedForAvatar

```solidity
event CompanyJumpedForAvatar(address avatar, uint256 portalId, uint256 fee)
```

### CompanyUpgradedExperience

```solidity
event CompanyUpgradedExperience(address experience, address nextVersion)
```

### CompanyUpgradedAsset

```solidity
event CompanyUpgradedAsset(address asset, address nextVersion)
```

### CompanyUpgraded

```solidity
event CompanyUpgraded(address oldVersion, address nextVersion)
```

### CompanyHookSet

```solidity
event CompanyHookSet(address hook)
```

### CompanyHookRemoved

```solidity
event CompanyHookRemoved()
```

### AssetMinted

```solidity
event AssetMinted(address asset, address to, uint256 amountOrTokenId)
```

### AssetRevoked

```solidity
event AssetRevoked(address asset, address holder, uint256 amountOrTokenId)
```

### CompanyDeactivated

```solidity
event CompanyDeactivated()
```

### CompanyReactivated

```solidity
event CompanyReactivated()
```

### init

```solidity
function init(struct CompanyInitArgs args) external
```

### world

```solidity
function world() external view returns (address)
```

_Returns the address of the world in which the company operates._

### vectorAddress

```solidity
function vectorAddress() external view returns (struct VectorAddress)
```

_Returns the vector address of the company. The vector address is assigned by
the operating World._

### canMintERC20

```solidity
function canMintERC20(address asset, address to, uint256 amount) external view returns (bool)
```

_Returns whether this company can mint the given asset to the given address.
The data parameter is dependent on the type of asset._

### canMintERC721

```solidity
function canMintERC721(address asset, address to) external view returns (bool)
```

_Returns whether this company can mint the given ERC721 to the given address._

### setERC721BaseURI

```solidity
function setERC721BaseURI(address asset, string baseURI) external
```

_Sets a new BaseURI for an ERC721 asset. This should only be called by admins_

### addExperience

```solidity
function addExperience(struct AddExperienceArgs args) external returns (address, uint256)
```

_Adds an experience to the world. This also creates a portal into the 
experience and registers it in the PortalRegistry. It is assumed that the 
initialization data for the experience will include the expected fee
for the portal._

### deactivateExperience

```solidity
function deactivateExperience(address experience, string reason) external
```

_Deactivates an experience. This will prevent avatars from entering the experience
but will not remove the experience from the world. This can only be called by the
company admin._

### reactivateExperience

```solidity
function reactivateExperience(address experience) external
```

_Reactivates an experience that was previously deactivated. This can only be called
by the company admin._

### removeExperience

```solidity
function removeExperience(address experience, string reason) external
```

_Removes an experience from the world. This also removes the portal into the 
experience and unregisters it from the PortalRegistry. This can only be called
by company admin_

### mintERC20

```solidity
function mintERC20(address asset, address to, uint256 amount) external
```

_Mints the given asset to the given address with the given amount._

### mintERC721

```solidity
function mintERC721(address asset, address to) external
```

_Mints an ERC721 to the given address. The token ID associated with the 
minted asset is an incremental counter for the asset. This is intentionally
decoupled from its originating asset on another chain to preserve privacy._

### revokeERC20

```solidity
function revokeERC20(address asset, address holder, uint256 amount) external
```

_Revokes the given amount of the given asset from the given address. The data
parameter is dependent on the type of asset. This is likely called when an avatar
owner transfers the original asset on another chain (i.e. all assets in the 
interoperability layer are synthetic assets that represent assets on other chains)._

### revokeERC721

```solidity
function revokeERC721(address asset, address holder, uint256 tokenId) external
```

_Revokes the given ERC721 token from the given address. This is likely called
when an avatar owner transfers the original asset on another chain (i.e. all assets
in the interoperability layer are synthetic assets that represent assets on other chains)._

### withdraw

```solidity
function withdraw(uint256 amount) external
```

_Withdraws the given amount of funds from the company. Only the owner can withdraw funds._

### addExperienceCondition

```solidity
function addExperienceCondition(address experience, address condition) external
```

_Adds an experience condition to an experience. Going through the company
contract provides the necessary authorization checks and that only the experience
owner can add conditions._

### removeExperienceCondition

```solidity
function removeExperienceCondition(address experience) external
```

_Removes an experience condition from an experience_

### changeExperiencePortalFee

```solidity
function changeExperiencePortalFee(address experience, uint256 fee) external
```

_Changes the fee associated with a portal to an experience owned by the company.
Going through the company provides appropriate authorization checks._

### addAssetCondition

```solidity
function addAssetCondition(address asset, address condition) external
```

_Adds an asset condition to an asset. Going through the company
contract provides the necessary authorization checks and that only the asset
issuer can add conditions._

### removeAssetCondition

```solidity
function removeAssetCondition(address asset) external
```

_Removes an asset condition from an asset_

### delegateJumpForAvatar

```solidity
function delegateJumpForAvatar(struct DelegatedAvatarJumpRequest request) external
```

_Delegates a jump for an avatar to the company. This allows the company to
pay the transaction fee but charge the avatar owner for the jump. This is useful
for companies that want to offer free jumps to avatars but charge them for the
experience._

## CompanyStorage

```solidity
struct CompanyStorage {
  uint256 nextPSubValue;
}
```

## LibCompany

### load

```solidity
function load() internal pure returns (struct CompanyStorage ws)
```

## CompanyRegistryConstructorArgs

```solidity
struct CompanyRegistryConstructorArgs {
  address worldRegistry;
}
```

## CompanyRegistry

_A registry for Company entities_

### worldRegistry

```solidity
contract IWorldRegistry worldRegistry
```

### onlyActiveWorld

```solidity
modifier onlyActiveWorld()
```

### onlySigner

```solidity
modifier onlySigner()
```

### constructor

```solidity
constructor(struct CompanyRegistryConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

### createCompany

```solidity
function createCompany(struct CreateCompanyArgs args) external returns (address)
```

_create a company and register it in this registry._

## CompanyRegistryProxy

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) public
```

## CreateCompanyArgs

```solidity
struct CreateCompanyArgs {
  bool sendTokensToOwner;
  address owner;
  string name;
  struct RegistrationTerms terms;
  struct VectorAddress vector;
  bytes initData;
  bytes ownerTermsSignature;
  uint256 expiration;
}
```

## ICompanyRegistry

### createCompany

```solidity
function createCompany(struct CreateCompanyArgs args) external returns (address)
```

## ExperienceConstructorArgs

```solidity
struct ExperienceConstructorArgs {
  address companyRegistry;
  address experienceRegistry;
  address portalRegistry;
}
```

## ExperienceInitData

```solidity
struct ExperienceInitData {
  uint256 entryFee;
  bytes connectionDetails;
}
```

## Experience

### companyRegistry

```solidity
address companyRegistry
```

### experienceRegistry

```solidity
contract IExperienceRegistry experienceRegistry
```

### portalRegistry

```solidity
contract IPortalRegistry portalRegistry
```

### onlyCompany

```solidity
modifier onlyCompany()
```

### onlyPortalRegistry

```solidity
modifier onlyPortalRegistry()
```

### constructor

```solidity
constructor(struct ExperienceConstructorArgs args) public
```

### version

```solidity
function version() public pure returns (struct Version)
```

_Returns the version of the entity._

### init

```solidity
function init(struct ExperienceInitArgs args) public
```

_initialize storage for a new experience. This can only be called by the experience registry_

### initPortal

```solidity
function initPortal() public returns (uint256 portal)
```

_Initializes the portal for the experience. This can only be called by the experience registry
and must be called AFTER initialization. This is because the portal registry will require that 
the caller (this experience) is registered, and registration requires certain information about 
the experience that is set during initialization._

### portalId

```solidity
function portalId() public view returns (uint256)
```

_Returns the portal id attached to this experience_

### deactivate

```solidity
function deactivate(string reason) public
```

_Deactivates the experience. This can only be called by the experience registry. This also
deactivates the portal associated with the experience._

### reactivate

```solidity
function reactivate() public
```

_Reactivates the experience. This can only be called by the experience registry. This also
reactivates the portal associated with the experience._

### remove

```solidity
function remove(string reason) public
```

_Removes the experience. This can only be called by the experience registry. This also
removes the portal associated with the experience._

### getExperienceInfo

```solidity
function getExperienceInfo(address experience) external view returns (struct ExperienceInfo)
```

_Returns information about this experience_

### owningRegistry

```solidity
function owningRegistry() internal view returns (address)
```

_Returns the owning registry for this entity_

### company

```solidity
function company() public view returns (address)
```

_Returns the company that controls this experience_

### world

```solidity
function world() public view returns (address)
```

_Returns the world that this experience is in_

### vectorAddress

```solidity
function vectorAddress() public view returns (struct VectorAddress)
```

_Returns the spatial vector address for this experience, which is derived
from its parent company and world._

### entryFee

```solidity
function entryFee() public view returns (uint256)
```

_Returns the entry fee for this experience_

### addPortalCondition

```solidity
function addPortalCondition(address condition) public
```

_Adds a portal condition to the experience. This can only be called by the parent company contract_

### removePortalCondition

```solidity
function removePortalCondition() public
```

_Removes the portal condition from the experience. This can only be called by the parent company contract_

### changePortalFee

```solidity
function changePortalFee(uint256 fee) public
```

_Changes the portal fee for this experience. This can only be called by the parent company contract_

### connectionDetails

```solidity
function connectionDetails() public view returns (bytes)
```

_Returns information on how to connect to the experience. This is dependent on
the client and company implementation and will likely need to be decoded by the
company's infrastructure or API when a client attempts to jump into the experience._

### setConnectionDetails

```solidity
function setConnectionDetails(bytes details) public
```

_Sets the connection details for the experience. This can only be called by the parent company contract_

### entering

```solidity
function entering(struct JumpEntryRequest) public payable returns (bytes)
```

_Called when an avatar jumps into this experience. This can only be called by the 
portal registry so that any portal condition is evaluated before entering the experience._

## ExperienceProxy

### constructor

```solidity
constructor(address reg) public
```

## JumpEntryRequest

_Entry request when an avatar jumps into an experience_

```solidity
struct JumpEntryRequest {
  address sourceWorld;
  address sourceCompany;
  address avatar;
}
```

## ExperienceInitArgs

```solidity
struct ExperienceInitArgs {
  string name;
  address company;
  struct VectorAddress vector;
  bytes initData;
}
```

## ExperienceInfo

```solidity
struct ExperienceInfo {
  address company;
  address world;
  uint256 portalId;
}
```

## IExperience

_Interface for an experience. An experience is something a Company offers within a 
World. Avatars portal into experiences to interact with them. Portaling into an Experience
may incur a fee paid by the Avatar. An Experience may have hooks that are called when an
Avatar enters the experience that can further evaluate the request outside of Portal conditions._

### ConnectionDetailsChanged

```solidity
event ConnectionDetailsChanged(bytes newDetails)
```

### JumpEntry

```solidity
event JumpEntry(address sourceWorld, address sourceCompany, address avatar, uint256 attachedFees)
```

### HookAdded

```solidity
event HookAdded(address hook)
```

### HookRemoved

```solidity
event HookRemoved(address hook)
```

### ExperienceUpgraded

```solidity
event ExperienceUpgraded(address oldVersion, address newVersion)
```

### PortalFeeChanged

```solidity
event PortalFeeChanged(uint256 newFee)
```

### ExperienceDeactivated

```solidity
event ExperienceDeactivated()
```

### init

```solidity
function init(struct ExperienceInitArgs args) external
```

_Initializes the experience with the given arguments. This is called after cloning the experience
proxy and assigning this contract as its logic. It can only be called once and by its registry._

### initPortal

```solidity
function initPortal() external returns (uint256 portalId)
```

_Initializes the portal for this experience. This is called after initialization and
registration in the experience registry. It can only be called once and by its registry._

### company

```solidity
function company() external view returns (address)
```

_Returns the company that controls this experience_

### world

```solidity
function world() external view returns (address)
```

_Returns the world that this experience is in_

### portalId

```solidity
function portalId() external view returns (uint256)
```

_Returns the portal id attached to this experience_

### vectorAddress

```solidity
function vectorAddress() external view returns (struct VectorAddress)
```

_Returns the spatial vector address for this experience, which is derived
from its parent company and world._

### entryFee

```solidity
function entryFee() external view returns (uint256)
```

_Returns the entry fee for this experience_

### addPortalCondition

```solidity
function addPortalCondition(address condition) external
```

_Adds a portal condition to the experience. This can only be called by the parent company contract_

### removePortalCondition

```solidity
function removePortalCondition() external
```

_Removes the portal condition from the experience. This can only be called by the parent company contract_

### changePortalFee

```solidity
function changePortalFee(uint256 fee) external
```

_Changes the portal fee for this experience. This can only be called by the parent company contract_

### connectionDetails

```solidity
function connectionDetails() external view returns (bytes)
```

_Returns information on how to connect to the experience. This is dependent on
the client and company implementation and will likely need to be decoded by the
company's infrastructure or API when a client attempts to jump into the experience._

### setConnectionDetails

```solidity
function setConnectionDetails(bytes details) external
```

_Sets the connection details for the experience. This can only be called by the parent company contract_

### entering

```solidity
function entering(struct JumpEntryRequest request) external payable returns (bytes)
```

_Called when an avatar jumps into this experience. This can only be called by the 
portal registry so that any portal condition is evaluated before entering the experience._

### getExperienceInfo

```solidity
function getExperienceInfo(address exp) external view returns (struct ExperienceInfo)
```

_Returns the experience info for the given experience address._

## ExperienceStorage

```solidity
struct ExperienceStorage {
  uint256 entryFee;
  uint256 portalId;
  bytes connectionDetails;
}
```

## LibExperience

### load

```solidity
function load() internal pure returns (struct ExperienceStorage ws)
```

## ExperienceRegistryConstructorArgs

```solidity
struct ExperienceRegistryConstructorArgs {
  address companyRegistry;
  address worldRegistry;
}
```

## ExperienceRegistry

_A registry for experiences. Experiences are created and controlled through company contracts._

### companyRegistry

```solidity
contract ICompanyRegistry companyRegistry
```

### worldRegistry

```solidity
contract IWorldRegistry worldRegistry
```

### onlyWorldCompanyChain

```solidity
modifier onlyWorldCompanyChain(address company)
```

### constructor

```solidity
constructor(struct ExperienceRegistryConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

### createExperience

```solidity
function createExperience(struct CreateExperienceArgs args) external returns (address proxy, uint256 portalId)
```

_Creates a new experience. This can only be called by a world who also owns the company requested as the 
experience owner. Note that only a company can intiate the experience creation through its parent
 World contract; meaning, a World cannot act alone to create a new experience on behalf of a company._

### deactivateExperience

```solidity
function deactivateExperience(address company, address exp, string reason) external
```

_Deactivates an experience. This can only be called by the world registry. The company must be 
the owner of the experience. Company initiates this call through a world so that events are 
emitted for both the company and world for tracking purposes. The company must also belong to the world._

### reactivateExperience

```solidity
function reactivateExperience(address company, address exp) external
```

_Reactivates an experience. This can only be called by the world registry. The company must be 
the owner of the experience. Company initiates this call through a world so that events are 
emitted for both the company and world for tracking purposes. The company must also belong to the world._

### removeExperience

```solidity
function removeExperience(address company, address exp, string reason) external returns (uint256 portalId)
```

_Removes an experience from the registry. This can only be called by the world. The company must be
the owner of the experience. Company initiates this call through a world so that events are
emitted for both the company and world for tracking purposes. The company must also belong to the world._

### _verifyExpOwnership

```solidity
function _verifyExpOwnership(address company, address exp) internal view
```

## ExperienceRegistryProxy

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) public
```

## CreateExperienceArgs

```solidity
struct CreateExperienceArgs {
  address company;
  string name;
  struct VectorAddress vector;
  bytes initData;
}
```

## IExperienceRegistry

_The IExperienceRegistry contract is a registry for experiences. It is used to create, deactivate, and remove experiences.
All experience creations are initiated by a company contract but go through the company's parent
world contract. This is mostly to minimize off-chain logistics of monitoring experience state for 
both companies and worlds._

### createExperience

```solidity
function createExperience(struct CreateExperienceArgs args) external returns (address, uint256)
```

_Creates a new experience._

### deactivateExperience

```solidity
function deactivateExperience(address company, address exp, string reason) external
```

_Deactivates an experience. This can only be called by a world. The company must be 
the owner of the experience. Company initiates this call through a world so that events are 
emitted for both the company and world for tracking purposes. The company must also belong to the world._

### reactivateExperience

```solidity
function reactivateExperience(address company, address exp) external
```

_Reactivates an experience. This can only be called by a world. The company must be 
the owner of the experience. Company initiates this call through a world so that events are 
emitted for both the company and world for tracking purposes. The company must also belong to the world._

### removeExperience

```solidity
function removeExperience(address company, address exp, string reason) external returns (uint256 portalId)
```

_Removes an experience from the registry. This can only be called by a world. The company must be
the owner of the experience. Company initiates this call through a world so that events are
emitted for both the company and world for tracking purposes. The company must also belong to the world._

## IAccessControl

_The IAccessControl is the interface for managing roles and signers._

### hasRole

```solidity
function hasRole(bytes32 role, address account) external view returns (bool)
```

### grantRole

```solidity
function grantRole(bytes32 role, address account) external
```

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) external
```

### addSigners

```solidity
function addSigners(address[] signers) external
```

### removeSigners

```solidity
function removeSigners(address[] signers) external
```

### isSigner

```solidity
function isSigner(address account) external view returns (bool)
```

### isAdmin

```solidity
function isAdmin(address account) external view returns (bool)
```

### owner

```solidity
function owner() external view returns (address)
```

### changeOwner

```solidity
function changeOwner(address newOwner) external
```

## IRegisteredEntity

_The IRegisteredEntity contract is the base interface for all registered entities (Worlds, 
Companies, Experiences, etc.). It provides a name and version for the entity._

### name

```solidity
function name() external view returns (string)
```

_Returns the name of the entity._

### version

```solidity
function version() external view returns (struct Version)
```

_Returns the version of the entity._

## IRemovable

_The IRemovable contract is the interface for entities that can be deactivated and removed._

### EntityDeactivated

```solidity
event EntityDeactivated(address by, string reason)
```

### EntityReactivated

```solidity
event EntityReactivated(address by)
```

### EntityRemoved

```solidity
event EntityRemoved(address by, string reason)
```

### termsOwner

```solidity
function termsOwner() external view returns (address)
```

_Returns the address of the authority that can deactivate and remove the entity and set
registration terms._

### deactivate

```solidity
function deactivate(string reason) external
```

_Deactivates the entity. This can only be called by the entity's registry but 
is initiated by the terms owner._

### reactivate

```solidity
function reactivate() external
```

_Reactivates the entity. This can only be called by the entity's registry but 
is initiated by the terms owner._

### remove

```solidity
function remove(string reason) external
```

_Removes the entity from the registry. This can only be called by the entity's registry but 
is initiated by the terms owner._

### isEntityActive

```solidity
function isEntityActive() external view returns (bool)
```

_Determines if the entity is still active._

### isRemoved

```solidity
function isRemoved() external view returns (bool)
```

_Determines if the entity is removed._

## IRemovableEntity

_The IRemovableEntity contract is the interface for entities that can be deactivated and removed._

## IEntityRemoval

_The IEntityRemoval contract is the interface for removing entities from a registry. There are 
two ways entities can be deactivated and/or removed. The terms owner can deactivate or reactivated
entities at will. The terms owner can also remove an entity but only after a grace period following
deactivation. 

The second way is if the registration terms expire. In this case anyone can enforce deactivation
and ultimate removal._

### RegistryDeactivatedEntity

```solidity
event RegistryDeactivatedEntity(address entity, string reason)
```

### RegistryReactivatedEntity

```solidity
event RegistryReactivatedEntity(address entity)
```

### RegistryRemovedEntity

```solidity
event RegistryRemovedEntity(address entity, string reason)
```

### RegistryEnforcedDeactivation

```solidity
event RegistryEnforcedDeactivation(address entity)
```

### RegistryEnforcedRemoval

```solidity
event RegistryEnforcedRemoval(address entity)
```

### EntityRegistrationRenewed

```solidity
event EntityRegistrationRenewed(address entity, address by)
```

### deactivateEntity

```solidity
function deactivateEntity(contract IRemovableEntity entity, string reason) external
```

_Called by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
mallicious activity. The entity can be reactivated by the terms owner._

### reactivateEntity

```solidity
function reactivateEntity(contract IRemovableEntity entity) external
```

_Called by the entity's terms owner to reactivate the entity._

### removeEntity

```solidity
function removeEntity(contract IRemovableEntity entity, string reason) external
```

_Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
the entity and waiting for the grace period to expire. A grace period must be set to given ample time
for the entity to respond to deactivation._

### getEntityTerms

```solidity
function getEntityTerms(address addr) external view returns (struct RegistrationTerms)
```

_Returns the terms for the given entity address_

### canBeDeactivated

```solidity
function canBeDeactivated(address addr) external view returns (bool)
```

_Returns whether an entity can be deactivated. Entities can only be deactivated
if they are either expired or within the grace period_

### canBeRemoved

```solidity
function canBeRemoved(address addr) external view returns (bool)
```

_Returns whether an entity can be removed. Entities can only be removed if they are
outside the grace period_

### enforceDeactivation

```solidity
function enforceDeactivation(contract IRemovableEntity addr) external
```

_Enforces deactivation of an entity. Can be called by anyone but will only
succeed if the entity is inside the grace period_

### enforceRemoval

```solidity
function enforceRemoval(contract IRemovableEntity e) external
```

_Enforces removal of an entity. Can be called by anyone but will only
succeed if it is outside the grace period_

### getLastRenewal

```solidity
function getLastRenewal(address addr) external view returns (uint256)
```

_Returns the last renewal timestamp in seconds for the given address._

### getExpiration

```solidity
function getExpiration(address addr) external view returns (uint256)
```

_Returns the expiration timestamp in seconds for the given address._

### isExpired

```solidity
function isExpired(address addr) external view returns (bool)
```

_Check whether an address is expired._

### isInGracePeriod

```solidity
function isInGracePeriod(address addr) external view returns (bool)
```

_Check whether an address is in the grace period._

### renewEntity

```solidity
function renewEntity(address addr) external payable
```

_Renew an entity by paying the renewal fee._

## IRegistry

_The IRegistry contract is the base interface for a registry of entities. It covers the setting 
of proxy and implementation logic that registries use to clone with each entity registered. Note 
that each registry implementation will have its own registration scheme since different arguments
are required for different entities._

### RegistryAddedEntity

```solidity
event RegistryAddedEntity(address entity, address owner)
```

### RegistryUpgradedEntity

```solidity
event RegistryUpgradedEntity(address entity, address newImplementation)
```

### RegistryDowngradedEntity

```solidity
event RegistryDowngradedEntity(address entity, address newImplementation)
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

### setEntityImplementation

```solidity
function setEntityImplementation(address implementation) external
```

_Sets the entity logic implementation to use when registering new entities._

### getEntityImplementation

```solidity
function getEntityImplementation() external view returns (address)
```

_Returns the entity logic implementation._

### getEntityVersion

```solidity
function getEntityVersion() external view returns (struct Version)
```

_Gets the version of the entity logic implementation. Can be used 
detect upgradeability for the entity._

### setProxyImplementation

```solidity
function setProxyImplementation(address implementation) external
```

_Sets the entity proxy contract that is cloned for each new entity registered._

### getProxyImplementation

```solidity
function getProxyImplementation() external view returns (address)
```

_Returns the entity proxy implementation._

### isRegistered

```solidity
function isRegistered(address addr) external view returns (bool)
```

_Checks if an entity is registered in the registry_

### getEntityByName

```solidity
function getEntityByName(string name) external view returns (address)
```

_Gets the proxy address of any entity by its globally-uniqueu registered name. This
will NOT apply to asset-type entities, which are not registered by name._

## ChangeEntityTermsArgs

```solidity
struct ChangeEntityTermsArgs {
  address entity;
  bytes entitySignature;
  uint256 expiration;
  struct RegistrationTerms terms;
}
```

## IRemovableRegistry

_The IRemovableRegistry contract is the interface for registries that can remove entities._

### RegistrarDeactivatedWorld

```solidity
event RegistrarDeactivatedWorld(address world, string reason)
```

### RegistrarReactivatedWorld

```solidity
event RegistrarReactivatedWorld(address world)
```

### RegistrarRemovedWorld

```solidity
event RegistrarRemovedWorld(address world, string reason)
```

### changeEntityTerms

```solidity
function changeEntityTerms(struct ChangeEntityTermsArgs args) external
```

_A terms owner can change an entity's terms but only if an entity signer agrees to 
the change._

## ITermsOwner

_The ITermsOwner contract is the interface for authorities that determine an 
entity's active state and registration terms._

### isStillActive

```solidity
function isStillActive() external view returns (bool)
```

_Determines if the terms owner is still active._

### isTermsOwnerSigner

```solidity
function isTermsOwnerSigner(address a) external view returns (bool)
```

_Checks whether the given address is a signer for the terms owner._

## IVectoredRegistry

_The IVectoredRegistry contract is the interface for a registry of entities that can be
accessed by a vector address._

### getEntityByVector

```solidity
function getEntityByVector(struct VectorAddress vector) external view returns (address)
```

_Find the entity address by its vector address._

## AccessStorage

```solidity
struct AccessStorage {
  address owner;
  mapping(bytes32 => mapping(address => bool)) roles;
}
```

## LibAccess

_Access control logic is not likely to change or be upgradeable. It is, however, a highly used library
that incurs a lot of gas costs to maintain as a separate module. Early dev version used an access module
and it proved to add too much overhead for just verifying access. So it was moved into this library to
reduce gas costs and simplify the codebase._

### load

```solidity
function load() internal pure returns (struct AccessStorage a)
```

### initAccess

```solidity
function initAccess(address _owner, address[] admins) external
```

_Initializes the access control contract with an owner and a list of admins. Owners
and admins are also given signing privileges._

### owner

```solidity
function owner() external view returns (address)
```

_Returns the owner of the contract._

### setOwner

```solidity
function setOwner(address o) external
```

_Sets the owner of the contract. Should only be called by the current owner._

### addSigners

```solidity
function addSigners(address[] signers) external
```

_Adds a list of admins to the contract. Should only be called by an admin_

### removeSigners

```solidity
function removeSigners(address[] signers) external
```

_Removes a list of admins from the contract. Should only be called by an admin_

### isSigner

```solidity
function isSigner(address a) external view returns (bool)
```

_Returns true if the given address is a registered signer_

### isAdmin

```solidity
function isAdmin(address a) external view returns (bool)
```

_Returns true if the given address is a registered admin_

### hasRole

```solidity
function hasRole(bytes32 role, address account) external view returns (bool)
```

_Returns true if the given address has the specified role_

### grantRole

```solidity
function grantRole(bytes32 role, address account) external
```

_Grants a role to an address. Should only be called by an admin._

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) external
```

_Revokes a role from an address. Should only be called by an admin._

## AssetStorage

Storage structure for assets.

```solidity
struct AssetStorage {
  address originAddress;
  address issuer;
  contract IAssetCondition condition;
  uint256 originChainId;
  string symbol;
}
```

## LibAsset

### load

```solidity
function load() internal pure returns (struct AssetStorage store)
```

## Wearable

_wearable structure assumed to be an NFT asset contract with unique token id. The tokenId
is the XR chain id, not the original NFT token id._

```solidity
struct Wearable {
  address asset;
  uint256 tokenId;
}
```

## AvatarStorage

```solidity
struct AvatarStorage {
  bool canReceiveTokensOutsideExperience;
  address currentExperience;
  mapping(address => uint256) companyNonces;
  uint256 ownerNonce;
  bytes appearanceDetails;
  struct LinkedList list;
}
```

## LibAvatar

### load

```solidity
function load() internal pure returns (struct AvatarStorage ds)
```

## LibClone

### clone

```solidity
function clone(address impl) internal returns (address proxy)
```

## ERC20Storage

```solidity
struct ERC20Storage {
  uint8 decimals;
  uint256 maxSupply;
  uint256 totalSupply;
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowances;
}
```

## LibERC20

### load

```solidity
function load() internal pure returns (struct ERC20Storage store)
```

## ERC721Storage

```solidity
struct ERC721Storage {
  string baseURI;
  uint256 tokenIdCounter;
  mapping(uint256 => address) owners;
  mapping(address => uint256) balances;
  mapping(uint256 => address) tokenApprovals;
  mapping(address => mapping(address => bool)) operatorApprovals;
}
```

## LibERC721

### load

```solidity
function load() internal pure returns (struct ERC721Storage s)
```

### requireOwned

```solidity
function requireOwned(uint256 tokenId) internal view returns (address)
```

_require that the given token id has an owner and if so, return the owner address. Revert otherwise._

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) public view returns (bool)
```

_See {IERC721-isApprovedForAll}._

### _ownerOf

```solidity
function _ownerOf(uint256 tokenId) internal view returns (address)
```

_Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist

IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
`balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`._

### _getApproved

```solidity
function _getApproved(uint256 tokenId) internal view returns (address)
```

_Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted._

### _isAuthorized

```solidity
function _isAuthorized(address owner, address spender, uint256 tokenId) internal view returns (bool)
```

_Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
particular (ignoring whether it is owned by `owner`).

WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
assumption._

### _update

```solidity
function _update(address to, uint256 tokenId, address auth) internal returns (address)
```

_Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
(or `to`) is the zero address. Returns the owner of the `tokenId` before the update.

The `auth` argument is optional. If the value passed is non 0, then this function will check that
`auth` is either the owner of the token, or approved to operate on the token (by the owner).

Emits a {Transfer} event.

NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}._

### _checkAuthorized

```solidity
function _checkAuthorized(address owner, address spender, uint256 tokenId) internal view
```

_Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
Reverts if `spender` does not have approval from the provided `owner` for the given token or for all its assets
the `spender` for the specific `tokenId`.

WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
assumption._

### _approve

```solidity
function _approve(address to, uint256 tokenId, address auth) internal
```

_Approve `to` to operate on `tokenId`

The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
either the owner of the token, or approved to operate on all tokens held by this owner.

Emits an {Approval} event.

Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument._

### _approve

```solidity
function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal
```

_Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
emitted in the context of transfers._

## EntityStorage

```solidity
struct EntityStorage {
  string name;
}
```

## LibEntity

### load

```solidity
function load() internal pure returns (struct EntityStorage ds)
```

## LibEntityRemoval

_Library for managing the removal of entities from the registry. Entities can be deactivated, reactivated, and removed
by the terms owner. Entities can also be enforced to deactivate or remove by anyone if they are outside the grace period._

### DAY

```solidity
uint256 DAY
```

### deactivateEntity

```solidity
function deactivateEntity(contract IRemovableEntity entity, string reason) public
```

_Intiiated by the entity's terms owner to deactivate the entity. This is usually due to non-payment of fees or 
mallicious activity. The entity can be reactivated by the terms owner._

### reactivateEntity

```solidity
function reactivateEntity(contract IRemovableEntity entity) public
```

_Initiated by the entity's terms owner to reactivate the entity._

### removeEntity

```solidity
function removeEntity(contract IRemovableEntity entity, string reason) public
```

_Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
the entity and waiting for the grace period to expire. A grace period must be set to given ample time
for the entity to respond to deactivation._

### getEntityTerms

```solidity
function getEntityTerms(address addr) public view returns (struct RegistrationTerms)
```

_Returns the terms for the given entity address_

### canBeDeactivated

```solidity
function canBeDeactivated(address addr) public view returns (bool)
```

_Returns whether an entity can be deactivated. Entities can only be deactivated
if they are either expired or within the grace period_

### canBeRemoved

```solidity
function canBeRemoved(address addr) public view returns (bool)
```

_Returns whether an entity can be removed. Entities can only be removed if they are
outside the grace period_

### enforceDeactivation

```solidity
function enforceDeactivation(contract IRemovableEntity addr) public
```

_Enforces deactivation of an entity. Can be called by anyone but will only
succeed if the entity is inside the grace period_

### enforceRemoval

```solidity
function enforceRemoval(contract IRemovableEntity e) public
```

_Enforces removal of an entity. Can be called by anyone but will only
succeed if it is outside the grace period_

### getLastRenewal

```solidity
function getLastRenewal(address addr) external view returns (uint256)
```

_Returns the last renewal timestamp in seconds for the given address._

### getExpiration

```solidity
function getExpiration(address addr) external view returns (uint256)
```

_Returns the expiration timestamp in seconds for the given address._

### isExpired

```solidity
function isExpired(address addr) external view returns (bool)
```

_Check whether an address is expired._

### isInGracePeriod

```solidity
function isInGracePeriod(address addr) external view returns (bool)
```

_Check whether an address is in the grace period._

### renewEntity

```solidity
function renewEntity(address addr) external
```

_Renew an entity by paying the renewal fee._

## ExperienceStorage

```solidity
struct ExperienceStorage {
  uint256 entryFee;
  bytes connectionDetails;
}
```

## LibExperience

### load

```solidity
function load() internal pure returns (struct ExperienceStorage ws)
```

## FactoryStorage

```solidity
struct FactoryStorage {
  address entityImplementation;
  address proxyImplementation;
  struct Version entityVersion;
}
```

## LibFactory

### load

```solidity
function load() internal pure returns (struct FactoryStorage ds)
```

### setProxyImplementation

```solidity
function setProxyImplementation(address _proxyImplementation) external
```

_Sets the proxy implementation to clone for each entity created. This should
be restricted to admins._

### getProxyImplementation

```solidity
function getProxyImplementation() external view returns (address)
```

_Gets the current proxy implementation to clone for each entity created._

### setEntityImplementation

```solidity
function setEntityImplementation(address _entityImplementation) external
```

_Sets the entity implementation to clone for each entity created. This should
be restricted to admins._

### getEntityImplementation

```solidity
function getEntityImplementation() external view returns (address)
```

_Gets the current entity implementation to clone for each entity created._

### getEntityVersion

```solidity
function getEntityVersion() external view returns (struct Version)
```

_Gets the current entity version._

## Node

_node within a linked list structure where next/prev values are hashes of 
wearable asset/tokenId_

```solidity
struct Node {
  struct Wearable data;
  bytes32 prev;
  bytes32 next;
}
```

## LinkedList

_LinkedList structure to store wearable assets_

```solidity
struct LinkedList {
  bytes32 head;
  bytes32 tail;
  uint256 size;
  uint256 maxSize;
  mapping(bytes32 => struct Node) nodes;
}
```

## LibLinkedList

_Library to manage linked list of wearables_

### insert

```solidity
function insert(struct LinkedList list, struct Wearable wearable) external
```

_Insert a new wearable into the linked list_

### remove

```solidity
function remove(struct LinkedList list, struct Wearable wearable) external
```

_remove a wearable from the list_

### contains

```solidity
function contains(struct LinkedList list, struct Wearable wearable) external view returns (bool)
```

_check if the list contains a wearable_

### getAllItems

```solidity
function getAllItems(struct LinkedList list) external view returns (struct Wearable[])
```

_Get all wearables in the list. The list has a max capacity to prevent
gas exhaustion for read-only calls._

## PortalInfo

```solidity
struct PortalInfo {
  contract IExperience destination;
  contract IPortalCondition condition;
  uint256 fee;
  bool active;
}
```

## PortalRegistryStorage

```solidity
struct PortalRegistryStorage {
  mapping(uint256 => struct PortalInfo) portals;
  mapping(bytes32 => uint256) portalIdsByVectorHash;
  mapping(address => uint256) portalIdsByExperience;
  uint256 nextPortalId;
}
```

## LibPortal

### load

```solidity
function load() internal pure returns (struct PortalRegistryStorage store)
```

## RegistrationTerms

```solidity
struct RegistrationTerms {
  uint16 coveragePeriodDays;
  uint16 gracePeriodDays;
  uint256 fee;
}
```

## RegistrationWithTermsAndVector

```solidity
struct RegistrationWithTermsAndVector {
  address entity;
  address termsOwner;
  struct RegistrationTerms terms;
  struct VectorAddress vector;
}
```

## TermsSignatureVerification

```solidity
struct TermsSignatureVerification {
  address owner;
  address termsOwner;
  struct RegistrationTerms terms;
  uint256 expiration;
  bytes ownerTermsSignature;
}
```

## TermedRegistration

```solidity
struct TermedRegistration {
  address owner;
  struct RegistrationTerms terms;
  uint256 lastRenewed;
  uint256 deactivationTime;
}
```

## RegistrationStorage

```solidity
struct RegistrationStorage {
  mapping(address => struct TermedRegistration) removableRegistrations;
  mapping(address => bool) staticRegistrations;
  mapping(string => address) registrationsByName;
  mapping(bytes32 => address) registrationsByVector;
}
```

## LibRegistration

### DAY

```solidity
uint256 DAY
```

### load

```solidity
function load() internal pure returns (struct RegistrationStorage ds)
```

### isRegistered

```solidity
function isRegistered(address addr) public view returns (bool)
```

_Checks if an entity is registered._

### getEntityByName

```solidity
function getEntityByName(string nm) public view returns (address)
```

_Gets the entity registered by a name, if applicable. Some entities, like assets, do not
have globally unique names so a zero-address would be returned in those cases.

NOTE: A case-insensitive comparison is used to find the entity by name. This only applies to
ascii based names and does not trim whitespace. Off-chain resources need to ensure that names
do not have hidden characters, etc._

### getEntityByVector

```solidity
function getEntityByVector(struct VectorAddress vector) public view returns (address)
```

_Gets the entity registered by a vector address, if applicable_

### registerNonRemovableEntityIgnoreName

```solidity
function registerNonRemovableEntityIgnoreName(address entity) public
```

_Registers a non-removable entity ignoring the name._

### registerNonRemovableEntity

```solidity
function registerNonRemovableEntity(address entity) public
```

_Registers a non-removable entity. The name must be globally unique._

### registerRemovableEntity

```solidity
function registerRemovableEntity(address entity, address termsOwner, struct RegistrationTerms terms) public
```

_Registers a removable entity. The name must be globally unique._

### registerRemovableEntityIgnoreName

```solidity
function registerRemovableEntityIgnoreName(address entity, address termsOwner, struct RegistrationTerms terms) public
```

_Registers a removable entity ignoring the name._

### registerRemovableVectoredEntity

```solidity
function registerRemovableVectoredEntity(struct RegistrationWithTermsAndVector args) public
```

_Registers a removable entity with a vector address._

### registerRemovableVectoredEntityIgnoreName

```solidity
function registerRemovableVectoredEntityIgnoreName(struct RegistrationWithTermsAndVector args) public
```

_Registers a removable entity with a vector address, ignoring the name._

### changeEntityTerms

```solidity
function changeEntityTerms(struct ChangeEntityTermsArgs args) public
```

_Change the registration terms for an entity. This should be checked that the caller
is the authority for the entity. This checks that the entity agreed to the terms by
checking signature._

### verifyNewEntityTermsSignature

```solidity
function verifyNewEntityTermsSignature(struct TermsSignatureVerification args) public view
```

_Verify whether an entity owner agrees to new terms and fees._

### _verifyEntitySignature

```solidity
function _verifyEntitySignature(struct ChangeEntityTermsArgs args) internal view returns (struct RegistrationTerms)
```

_Verifies that an entity owner agrees to new terms and fees._

## RemovableEntityStorage

```solidity
struct RemovableEntityStorage {
  bool active;
  bool removed;
  address termsOwner;
  struct VectorAddress vector;
}
```

## LibRemovableEntity

### load

```solidity
function load() internal pure returns (struct RemovableEntityStorage ds)
```

## LibRoles

### ROLE_OWNER

```solidity
bytes32 ROLE_OWNER
```

### ROLE_ADMIN

```solidity
bytes32 ROLE_ADMIN
```

### ROLE_SIGNER

```solidity
bytes32 ROLE_SIGNER
```

### ROLE_VECTOR_AUTHORITY

```solidity
bytes32 ROLE_VECTOR_AUTHORITY
```

## LibStorageSlots

### ENTITY_PROXY_STORAGE

```solidity
bytes32 ENTITY_PROXY_STORAGE
```

### ENTITY_STORAGE

```solidity
bytes32 ENTITY_STORAGE
```

### ACCESS_STORAGE

```solidity
bytes32 ACCESS_STORAGE
```

### FACTORY_STORAGE

```solidity
bytes32 FACTORY_STORAGE
```

### REGISTRATION_STORAGE

```solidity
bytes32 REGISTRATION_STORAGE
```

### ACTIVATION_STORAGE

```solidity
bytes32 ACTIVATION_STORAGE
```

### WORLD_STORAGE

```solidity
bytes32 WORLD_STORAGE
```

### COMPANY_STORAGE

```solidity
bytes32 COMPANY_STORAGE
```

### AVATAR_STORAGE

```solidity
bytes32 AVATAR_STORAGE
```

### EXPERIENCE_STORAGE

```solidity
bytes32 EXPERIENCE_STORAGE
```

### ASSET_STORAGE

```solidity
bytes32 ASSET_STORAGE
```

### ASSET_REGISTRY

```solidity
bytes32 ASSET_REGISTRY
```

### ERC20_ASSET_STORAGE

```solidity
bytes32 ERC20_ASSET_STORAGE
```

### ERC721_ASSET_STORAGE

```solidity
bytes32 ERC721_ASSET_STORAGE
```

### PORTAL_STORAGE

```solidity
bytes32 PORTAL_STORAGE
```

## LibStringCase

### lower

```solidity
function lower(string _base) internal pure returns (string)
```

Lower

Converts all the values of a string to their corresponding lower case
value.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _base | string | When being used for a data type this is the extended object              otherwise this is the string base to convert to lower case |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | string | string |

## VectorAddress

_A struct representing a vector address. A vector address is a unique identifier 
referencing a virtual spatial address. It is composed of a 3D vector (x, y, z) and 
temporal value (t), a planar value (p), and a dimension within the plane (p_sub). 
Worlds are given a base vector address by a Registrar, who obtains the address from
XRDNA as the address authority. Worlds then assign sub-locations within their world
to companies, which increments the planar value (p) within the world. Companies can
then assign sub-planar locations (p_sub) to experiences within their company and outer 
world. 

This means an experience vector address can be mapped back to its company and world
by setting its p_sub value to 0 and p value to 0 respectively._

```solidity
struct VectorAddress {
  string x;
  string y;
  string z;
  uint256 t;
  uint256 p;
  uint256 p_sub;
}
```

## LibVectorAddress

### asLookupKey

```solidity
function asLookupKey(struct VectorAddress self) public pure returns (string)
```

_Returns a string representation of the vector address. This is used to hash
the vector address and/or use it as a key in a map_

### validate

```solidity
function validate(struct VectorAddress self, bool needsP, bool needsPSub) public pure
```

### equals

```solidity
function equals(struct VectorAddress self, struct VectorAddress other) public pure returns (bool)
```

_Returns true if the two vector addresses are equal_

### getSigner

```solidity
function getSigner(struct VectorAddress self, address registrar, bytes signature) public pure returns (address)
```

_Returns the address of the signer of the vector address. The signer is the 
registrar that assigned the vector address to the world._

## Version

```solidity
struct Version {
  uint16 major;
  uint16 minor;
}
```

## LibVersion

### equals

```solidity
function equals(struct Version a, struct Version b) internal pure returns (bool)
```

### greaterThan

```solidity
function greaterThan(struct Version a, struct Version b) internal pure returns (bool)
```

### lessThan

```solidity
function lessThan(struct Version a, struct Version b) internal pure returns (bool)
```

## JumpEvaluationArgs

```solidity
struct JumpEvaluationArgs {
  address destinationExperience;
  address sourceWorld;
  address sourceCompany;
  address sourceExperience;
  address avatar;
}
```

## IPortalCondition

_Interface for portal conditions. Conditions allow additional rules to be attached
to a portal, which must be satisfied before a jump can be made._

### canJump

```solidity
function canJump(struct JumpEvaluationArgs args) external returns (bool)
```

_Returns whether the given avatar can jump to the destination experience from 
the source experience, company, and world._

## AddPortalRequest

```solidity
struct AddPortalRequest {
  uint256 fee;
}
```

## IPortalRegistry

### JumpSuccessful

```solidity
event JumpSuccessful(uint256 portalId, address avatar, address destination)
```

### PortalAdded

```solidity
event PortalAdded(uint256 portalId, address experience)
```

### PortalDeactivated

```solidity
event PortalDeactivated(uint256 portalId, address experience, string reason)
```

### PortalReactivated

```solidity
event PortalReactivated(uint256 portalId, address experience)
```

### PortalRemoved

```solidity
event PortalRemoved(uint256 portalId, address experience, string reason)
```

### PortalConditionAdded

```solidity
event PortalConditionAdded(uint256 portalId, address condition)
```

### PortalConditionRemoved

```solidity
event PortalConditionRemoved(uint256 portalId)
```

### PortalRegistryUpgraded

```solidity
event PortalRegistryUpgraded(address newRegistry)
```

### PortalFeeChanged

```solidity
event PortalFeeChanged(uint256 portalId, uint256 newFee)
```

### PortalDestinationUpgraded

```solidity
event PortalDestinationUpgraded(uint256 portalId, address oldExperience, address newExperience)
```

### version

```solidity
function version() external pure returns (struct Version)
```

### getPortalInfoById

```solidity
function getPortalInfoById(uint256 portalId) external view returns (struct PortalInfo)
```

_Returns the portal info for the given portal ID_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal |

### getPortalInfoByAddress

```solidity
function getPortalInfoByAddress(address experience) external view returns (struct PortalInfo)
```

_Returns the portal info for the given experience address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| experience | address | The address of the experience contract |

### getPortalInfoByVectorAddress

```solidity
function getPortalInfoByVectorAddress(struct VectorAddress va) external view returns (struct PortalInfo)
```

_Returns the portal info for the given vector address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| va | struct VectorAddress | The vector address for a destination experience |

### getIdForExperience

```solidity
function getIdForExperience(address experience) external view returns (uint256)
```

_Returns the portal ID for the given experience address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| experience | address | The address of the experience contract |

### getIdForVectorAddress

```solidity
function getIdForVectorAddress(struct VectorAddress va) external view returns (uint256)
```

_Returns the portal ID for the given vector address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| va | struct VectorAddress | The vector address for a destination experience |

### addPortal

```solidity
function addPortal(struct AddPortalRequest) external returns (uint256)
```

### deactivatePortal

```solidity
function deactivatePortal(uint256 portalId, string reason) external
```

_Deactivates a portal. This must be called by the experience registry
when an experience is deactivated._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal to deactivate |
| reason | string | The reason for deactivating the portal |

### reactivatePortal

```solidity
function reactivatePortal(uint256 portalId) external
```

_Reactivates a portal. This must be called by the experience registry
when an experience is reactivated._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal to reactivate |

### removePortal

```solidity
function removePortal(uint256 portalId, string reason) external
```

_Removes a portal from the registry. This must be called by the experience registry
when an experience is removed._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal to remove |
| reason | string | The reason for removing the portal |

### jumpRequest

```solidity
function jumpRequest(uint256 portalId) external payable returns (bytes)
```

_Initiates a jump request to the destination experience. This must be called
by a registered avatar contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The destination portal id to jump to |

### addCondition

```solidity
function addCondition(contract IPortalCondition condition) external
```

_Adds a condition to an existing portal. This must be called by the destination experience
contract, which is likely called by the company contract, to authenticate that the 
request is allowed by the company owning the experience._

### removeCondition

```solidity
function removeCondition() external
```

_Removes a condition from an existing portal. This must be called by the destination experience
contract, which is likely called by the company contract, to authenticate that the 
request is allowed by the company owning the experience._

### changePortalFee

```solidity
function changePortalFee(uint256 newFee) external
```

_Changes the fee for a portal. This must be called by the destination experience_

## PortalRegistryConstructorArgs

```solidity
struct PortalRegistryConstructorArgs {
  address avatarRegistry;
  address experienceRegistry;
}
```

## PortalRegistry

### PortalJumpMetadata

```solidity
struct PortalJumpMetadata {
  contract IExperience sourceExperience;
  contract IExperience destinationExperience;
  address sourceWorld;
  address sourceCompany;
  address destWorld;
  address destCompany;
  struct PortalInfo sourcePortal;
  struct PortalInfo destPortal;
}
```

### experienceRegistry

```solidity
contract IExperienceRegistry experienceRegistry
```

### avatarRegistry

```solidity
contract IAvatarRegistry avatarRegistry
```

### onlyActiveExperience

```solidity
modifier onlyActiveExperience()
```

### onlyExperience

```solidity
modifier onlyExperience()
```

### onlyAvatar

```solidity
modifier onlyAvatar()
```

### constructor

```solidity
constructor(struct PortalRegistryConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

### getPortalInfoById

```solidity
function getPortalInfoById(uint256 portalId) external view returns (struct PortalInfo)
```

_Returns the portal info for the given portal ID_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal |

### getPortalInfoByAddress

```solidity
function getPortalInfoByAddress(address experience) external view returns (struct PortalInfo)
```

_Returns the portal info for the given experience address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| experience | address | The address of the experience contract |

### getPortalInfoByVectorAddress

```solidity
function getPortalInfoByVectorAddress(struct VectorAddress va) external view returns (struct PortalInfo)
```

_Returns the portal info for the given vector address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| va | struct VectorAddress | The vector address for a destination experience |

### getIdForExperience

```solidity
function getIdForExperience(address experience) external view returns (uint256)
```

_Returns the portal ID for the given experience address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| experience | address | The address of the experience contract |

### getIdForVectorAddress

```solidity
function getIdForVectorAddress(struct VectorAddress va) external view returns (uint256)
```

_Returns the portal ID for the given vector address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| va | struct VectorAddress | The vector address for a destination experience |

### addPortal

```solidity
function addPortal(struct AddPortalRequest req) external returns (uint256)
```

### changePortalFee

```solidity
function changePortalFee(uint256 newFee) external
```

_Changes the fee for a portal. This must be called by the destination experience_

### deactivatePortal

```solidity
function deactivatePortal(uint256 portalId, string reason) external
```

_Deactivates a portal. This must be called by the experience registry
when an experience is deactivated._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal to deactivate |
| reason | string | The reason for deactivating the portal |

### reactivatePortal

```solidity
function reactivatePortal(uint256 portalId) external
```

_Reactivates a portal. This must be called by the experience registry
when an experience is reactivated._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal to reactivate |

### removePortal

```solidity
function removePortal(uint256 portalId, string reason) external
```

_Removes a portal from the registry. This must be called by the experience registry
when an experience is removed._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The ID of the portal to remove |
| reason | string | The reason for removing the portal |

### addCondition

```solidity
function addCondition(contract IPortalCondition condition) external
```

_Adds a condition to an existing portal. This must be called by the destination experience
contract, which is likely called by the company contract, to authenticate that the 
request is allowed by the company owning the experience._

### removeCondition

```solidity
function removeCondition() external
```

_Removes a condition from an existing portal. This must be called by the destination experience
contract, which is likely called by the company contract, to authenticate that the 
request is allowed by the company owning the experience._

### jumpRequest

```solidity
function jumpRequest(uint256 portalId) external payable returns (bytes)
```

_Initiates a jump request to the destination experience. This must be called
by a registered avatar contract._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| portalId | uint256 | The destination portal id to jump to |

### _getExperienceDetails

```solidity
function _getExperienceDetails(uint256 destPortalId) internal returns (struct PortalRegistry.PortalJumpMetadata meta)
```

## PortalRegistryProxy

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) public
```

## NewWorldArgs

```solidity
struct NewWorldArgs {
  bool sendTokensToOwner;
  address owner;
  struct VectorAddress baseVector;
  string name;
  struct RegistrationTerms terms;
  bytes ownerTermsSignature;
  uint256 expiration;
  bytes vectorAuthoritySignature;
  bytes initData;
}
```

## IRegistrar

### RegistrarAddedWorld

```solidity
event RegistrarAddedWorld(address world, address owner)
```

### RegistrarDeactivatedWorld

```solidity
event RegistrarDeactivatedWorld(address world, string reason)
```

### RegistrarReactivatedWorld

```solidity
event RegistrarReactivatedWorld(address world)
```

### RegistrarRemovedWorld

```solidity
event RegistrarRemovedWorld(address world, string reason)
```

### init

```solidity
function init(string name, address owner, bytes initData) external
```

### registerWorld

```solidity
function registerWorld(struct NewWorldArgs args) external payable returns (address world)
```

_Registers a new world contract. Must be called by a registrar signer_

### deactivateWorld

```solidity
function deactivateWorld(address world, string reason) external
```

_Deactivates a world contract. Must be called by a registrar signer_

### reactivateWorld

```solidity
function reactivateWorld(address world) external
```

_Reactivates a world contract. Must be called by a registrar signer_

### removeWorld

```solidity
function removeWorld(address world, string reason) external
```

_Removes a world contract. Must be called by a registrar signer_

### withdraw

```solidity
function withdraw(uint256 amount) external
```

## RegistrarConstructorArgs

```solidity
struct RegistrarConstructorArgs {
  address registrarRegistry;
  address worldRegistry;
}
```

## Registrar

_Registrar is an entity that creates and manages worlds. This implementation logic is applied
to the registrar proxy, which is cloned for each new registrar instance._

### registrarRegistry

```solidity
address registrarRegistry
```

### worldRegistry

```solidity
contract IWorldRegistry worldRegistry
```

### constructor

```solidity
constructor(struct RegistrarConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the entity._

### owningRegistry

```solidity
function owningRegistry() internal view returns (address)
```

_Returns the address of the registry that owns this entity_

### init

```solidity
function init(string name, address owner, bytes) external
```

_Initializes the registrar. Must be called by the registry during registration_

### registerWorld

```solidity
function registerWorld(struct NewWorldArgs args) external payable returns (address world)
```

_Registers a new world contract. Must be called by a registrar signer_

### deactivateWorld

```solidity
function deactivateWorld(address world, string reason) external
```

_Deactivates a world contract. Must be called by a registrar signer_

### reactivateWorld

```solidity
function reactivateWorld(address world) external
```

_Reactivates a world contract. Must be called by a registrar signer_

### removeWorld

```solidity
function removeWorld(address world, string reason) external
```

_Removes a world contract. Must be called by a registrar signer_

### isStillActive

```solidity
function isStillActive() external view returns (bool)
```

_Returns whether the registrar is still active_

### isTermsOwnerSigner

```solidity
function isTermsOwnerSigner(address a) external view returns (bool)
```

_Returns whether the given address is a signer for the registrar_

### withdraw

```solidity
function withdraw(uint256 amount) external
```

## RegistrarProxy

### constructor

```solidity
constructor(address reg) public
```

## CreateNonRemovableRegistrarArgs

```solidity
struct CreateNonRemovableRegistrarArgs {
  bool sendTokensToOwner;
  address owner;
  string name;
  bytes initData;
}
```

## CreateRegistrarArgs

```solidity
struct CreateRegistrarArgs {
  bool sendTokensToOwner;
  address owner;
  uint256 expiration;
  struct RegistrationTerms terms;
  string name;
  bytes initData;
  bytes ownerTermsSignature;
}
```

## IRegistrarRegistry

### createNonRemovableRegistrar

```solidity
function createNonRemovableRegistrar(struct CreateNonRemovableRegistrarArgs args) external payable returns (address)
```

_Creates a new non-removable registrar with the given arguments._

### createRemovableRegistrar

```solidity
function createRemovableRegistrar(struct CreateRegistrarArgs args) external payable returns (address)
```

_Creates a new removable registrar with the given arguments. The registrar registry is 
the terms authority for the registrar._

### withdraw

```solidity
function withdraw(uint256 amount) external
```

_When regsitrars renew registration, any fees are passed to this contract as the registrar's
terms owner. This function allows the registry owner to withdraw funds collected by the registry._

## RegistrarRegistry

_RegistrarRegistry is a registry that creates and manages registrars. It is the terms authority for all registrars._

### onlySigner

```solidity
modifier onlySigner()
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

### createNonRemovableRegistrar

```solidity
function createNonRemovableRegistrar(struct CreateNonRemovableRegistrarArgs args) external payable returns (address)
```

_Creates a new non-removable registrar with the given arguments._

### createRemovableRegistrar

```solidity
function createRemovableRegistrar(struct CreateRegistrarArgs args) external payable returns (address proxy)
```

_Creates a new removable registrar with the given arguments. The registrar registry is 
the terms authority for the registrar._

### withdraw

```solidity
function withdraw(uint256 amount) public
```

_withdraw funds from the contract_

### deactivateEntity

```solidity
function deactivateEntity(contract IRemovableEntity entity, string reason) external
```

_Called by the entity's authority to deactivate the entity for the given reason._

### reactivateEntity

```solidity
function reactivateEntity(contract IRemovableEntity entity) external
```

_Called by the entity's terms owner to reactivate the entity._

### removeEntity

```solidity
function removeEntity(contract IRemovableEntity entity, string reason) external
```

_Removes an entity from the registry. Can only be called by the terms owner and only after deactivating
the entity and waiting for the grace period to expire. A grace period must be set to given ample time
for the entity to respond to deactivation._

### changeEntityTerms

```solidity
function changeEntityTerms(struct ChangeEntityTermsArgs args) public
```

_Returns the terms for the given entity address_

## RegistrarRegistryProxy

### constructor

```solidity
constructor(struct BaseProxyConstructorArgs args) public
```

## TestCondition

### allowed

```solidity
mapping(address => bool) allowed
```

### canJump

```solidity
function canJump(struct JumpEvaluationArgs args) external view returns (bool)
```

_Returns whether the given avatar can jump to the destination experience from 
the source experience, company, and world._

### setCanJump

```solidity
function setCanJump(address avatar, bool _canJump) public
```

## TestERC20

### constructor

```solidity
constructor(string name, string symbol) public
```

## TestERC721

### constructor

```solidity
constructor(string name, string symbol) public
```

### mint

```solidity
function mint(address to, uint256 tokenId) public
```

## NewCompanyArgs

```solidity
struct NewCompanyArgs {
  bool sendTokensToOwner;
  address owner;
  string name;
  struct RegistrationTerms terms;
  bytes ownerTermsSignature;
  uint256 expiration;
  bytes initData;
}
```

## NewAvatarArgs

```solidity
struct NewAvatarArgs {
  bool sendTokensToOwner;
  address owner;
  address startingExperience;
  string name;
  bytes initData;
}
```

## NewExperienceArgs

```solidity
struct NewExperienceArgs {
  struct VectorAddress vector;
  string name;
  bytes initData;
}
```

## WorldInitArgs

```solidity
struct WorldInitArgs {
  address owner;
  address termsOwner;
  struct VectorAddress vector;
  string name;
  bytes initData;
}
```

## IWorld

_IWorld is the interface for a world contract. A world registers companies and avatars as well as
add experiences for companies. It is the registration terms authority for all companies._

### WorldAddedCompany

```solidity
event WorldAddedCompany(address company, address owner, struct VectorAddress vector)
```

### WorldAddedAvatar

```solidity
event WorldAddedAvatar(address avatar, address owner)
```

### WorldAddedCompany

```solidity
event WorldAddedCompany(address company, address owner)
```

### WorldDeactivatedCompany

```solidity
event WorldDeactivatedCompany(address company, string reason)
```

### WorldReactivatedCompany

```solidity
event WorldReactivatedCompany(address company)
```

### WorldRemovedCompany

```solidity
event WorldRemovedCompany(address company, string reason)
```

### WorldAddedExperience

```solidity
event WorldAddedExperience(address experience, address company, uint256 portalId)
```

### WorldDeactivatedExperience

```solidity
event WorldDeactivatedExperience(address experience, address company, string reason)
```

### WorldReactivatedExperience

```solidity
event WorldReactivatedExperience(address experience, address company)
```

### WorldRemovedExperience

```solidity
event WorldRemovedExperience(address experience, address company, string reason, uint256 portalId)
```

### init

```solidity
function init(struct WorldInitArgs args) external
```

### baseVector

```solidity
function baseVector() external view returns (struct VectorAddress)
```

### withdraw

```solidity
function withdraw(uint256 amount) external
```

### registerCompany

```solidity
function registerCompany(struct NewCompanyArgs args) external payable returns (address company)
```

_Registers a new company contract. Must be called by a world signer_

### deactivateCompany

```solidity
function deactivateCompany(address company, string reason) external
```

_Deactivates a company contract. Must be called by a world signer_

### reactivateCompany

```solidity
function reactivateCompany(address company) external
```

_Reactivates a company contract. Must be called by a world signer_

### removeCompany

```solidity
function removeCompany(address company, string reason) external
```

_Removes a company contract. Must be called by a world signer_

### registerAvatar

```solidity
function registerAvatar(struct NewAvatarArgs args) external payable returns (address avatar)
```

_Registers a new avatar contract. Must be called by a world signer_

### addExperience

```solidity
function addExperience(struct NewExperienceArgs args) external returns (address experience, uint256 portalId)
```

_Add an experience to the world. This is called by the company offering the experience_

### deactivateExperience

```solidity
function deactivateExperience(address experience, string reason) external
```

_Deactivates a company contract. Must be called by owning company_

### reactivateExperience

```solidity
function reactivateExperience(address experience) external
```

_Reactivates an experience contract. Must be called by owning company_

### removeExperience

```solidity
function removeExperience(address experience, string reason) external returns (uint256 portalId)
```

_Removes a experience contract. Must be called by owning company_

## WorldStorage

```solidity
struct WorldStorage {
  uint256 nextPValue;
}
```

## LibWorld

### load

```solidity
function load() internal pure returns (struct WorldStorage ws)
```

## WorldConstructorArgs

```solidity
struct WorldConstructorArgs {
  address registrarRegistry;
  address worldRegistry;
  address avatarRegistry;
  address companyRegistry;
  address experienceRegistry;
}
```

## World

### worldRegistry

```solidity
address worldRegistry
```

### avatarRegistry

```solidity
contract IAvatarRegistry avatarRegistry
```

### companyRegistry

```solidity
contract ICompanyRegistry companyRegistry
```

### experienceRegistry

```solidity
contract IExperienceRegistry experienceRegistry
```

### onlyActiveCompany

```solidity
modifier onlyActiveCompany()
```

### constructor

```solidity
constructor(struct WorldConstructorArgs args) public
```

### version

```solidity
function version() public pure returns (struct Version)
```

_Returns the version of the entity._

### owningRegistry

```solidity
function owningRegistry() internal view returns (address)
```

_Returns the address of the registry that owns this entity_

### init

```solidity
function init(struct WorldInitArgs args) public
```

### baseVector

```solidity
function baseVector() public view returns (struct VectorAddress)
```

_Returns the base vector for the world_

### isStillActive

```solidity
function isStillActive() public view returns (bool)
```

_Returns whether the world is still active_

### isTermsOwnerSigner

```solidity
function isTermsOwnerSigner(address a) public view returns (bool)
```

_Returns whether the given address is a signer for the world. The world is terms
owner for companies._

### withdraw

```solidity
function withdraw(uint256 amount) public
```

_Allows withdraw of registration renewal fees_

### registerCompany

```solidity
function registerCompany(struct NewCompanyArgs args) public payable returns (address company)
```

_Registers a new company contract. Must be called by a world signer_

### deactivateCompany

```solidity
function deactivateCompany(address company, string reason) public
```

_Deactivates a company contract. Must be called by a world signer_

### reactivateCompany

```solidity
function reactivateCompany(address company) public
```

_Reactivates a company contract. Must be called by a world signer_

### removeCompany

```solidity
function removeCompany(address company, string reason) public
```

_Removes a company contract. Must be called by a world signer_

### registerAvatar

```solidity
function registerAvatar(struct NewAvatarArgs args) public payable returns (address avatar)
```

_Registers a new avatar contract. Must be called by a world signer_

### addExperience

```solidity
function addExperience(struct NewExperienceArgs args) public returns (address experience, uint256 portalId)
```

_Add an experience to the world. This is called by the company offering the experience_

### deactivateExperience

```solidity
function deactivateExperience(address experience, string reason) public
```

_Deactivates a company contract. Must be called by owning company_

### reactivateExperience

```solidity
function reactivateExperience(address experience) public
```

_Reactivates an experience contract. Must be called by owning company_

### removeExperience

```solidity
function removeExperience(address experience, string reason) public returns (uint256 portalId)
```

_Removes a experience contract. Must be called by owning company_

## WorldProxy

### constructor

```solidity
constructor(address reg) public
```

## CreateWorldArgs

_args for creating a new world_

```solidity
struct CreateWorldArgs {
  bool sendTokensToOwner;
  address owner;
  uint256 expiration;
  struct RegistrationTerms terms;
  struct VectorAddress vector;
  string name;
  bytes initData;
  bytes ownerTermsSignature;
  bytes vectorAuthoritySignature;
}
```

## ChangeRegistrarArgs

_Worlds can switch registrars. This requires a signature from the current registrar, if 
still active, as well as signature of world owner on the new terms._

```solidity
struct ChangeRegistrarArgs {
  address entity;
  bytes oldRegistrarSignature;
  bytes entitySignature;
  uint256 expiration;
  struct RegistrationTerms newTerms;
}
```

## IWorldRegistry

_IWorldRegistry is the interface for a world registry contract. A world registry creates and manages
world contracts._

### RegistrarChangedForWorld

```solidity
event RegistrarChangedForWorld(address world, address oldRegistrar, address newRegistrar)
```

### createWorld

```solidity
function createWorld(struct CreateWorldArgs args) external returns (address)
```

_Creates a new world contract_

### isVectorAddressAuthority

```solidity
function isVectorAddressAuthority(address a) external view returns (bool)
```

_Checks if the given address is a vector address signing authority_

### addVectorAddressAuthority

```solidity
function addVectorAddressAuthority(address a) external
```

_Adds a new vector address authority_

### removeVectorAddressAuthority

```solidity
function removeVectorAddressAuthority(address a) external
```

_Removes a vector address authority_

### changeRegistrarWithTerms

```solidity
function changeRegistrarWithTerms(struct ChangeRegistrarArgs args) external
```

_Changes the registrar for a world contract_

## WorldRegistryConstructorArgs

```solidity
struct WorldRegistryConstructorArgs {
  address registrarRegistry;
}
```

## WorldRegistry

_A registry for creating and managing worlds_

### registrarRegistry

```solidity
contract IRegistrarRegistry registrarRegistry
```

### onlySigner

```solidity
modifier onlySigner()
```

### onlyActiveRegistrar

```solidity
modifier onlyActiveRegistrar()
```

### constructor

```solidity
constructor(struct WorldRegistryConstructorArgs args) public
```

### version

```solidity
function version() external pure returns (struct Version)
```

_Returns the version of the registry._

### isVectorAddressAuthority

```solidity
function isVectorAddressAuthority(address a) public view returns (bool)
```

_Checks if the given address is a vector address signing authority_

### addVectorAddressAuthority

```solidity
function addVectorAddressAuthority(address a) public
```

_Adds a new vector address authority_

### removeVectorAddressAuthority

```solidity
function removeVectorAddressAuthority(address a) public
```

_Removes a vector address authority_

### createWorld

```solidity
function createWorld(struct CreateWorldArgs args) public returns (address)
```

_Creates a new world contract_

### changeRegistrarWithTerms

```solidity
function changeRegistrarWithTerms(struct ChangeRegistrarArgs args) external
```

_Changes the registrar for a world contract_

### _verifyMigrationSigs

```solidity
function _verifyMigrationSigs(struct ChangeRegistrarArgs args) internal view
```

_Verify signatures when migrating to a new registrar_

## WorldRegistryProxyConstructorArgs

```solidity
struct WorldRegistryProxyConstructorArgs {
  address owner;
  address impl;
  address vectorAuthority;
  address[] admins;
}
```

## WorldRegistryProxy

### constructor

```solidity
constructor(struct WorldRegistryProxyConstructorArgs args) public
```


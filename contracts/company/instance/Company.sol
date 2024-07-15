// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {VectorAddress, LibVectorAddress} from '../../libraries/LibVectorAddress.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {ICompany, CompanyInitArgs, AddExperienceArgs, DelegatedAvatarJumpRequest} from './ICompany.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {CompanyStorage, LibCompany} from './LibCompany.sol';
import {IWorld, NewExperienceArgs} from '../../world/instance/IWorld.sol';
import {Version} from '../../libraries/LibVersion.sol';
import {IAssetRegistry} from '../../asset/registry/IAssetRegistry.sol';
import {IERC20Asset} from '../../asset/instance/erc20/IERC20Asset.sol';
import {IERC721Asset} from '../../asset/instance/erc721/IERC721Asset.sol';
import {IAvatarRegistry} from '../../avatar/registry/IAvatarRegistry.sol';
import {IAvatar, DelegatedJumpRequest} from '../../avatar/instance/IAvatar.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {IAsset} from '../../asset/instance/IAsset.sol';
import {ICompanyRegistry} from '../registry/ICompanyRegistry.sol';

struct CompanyConstructorArgs {
    address companyRegistry;
    address experienceRegistry;
    address erc20Registry;
    address erc721Registry;
    address avatarRegistry;
}

/** 
 * @title Company contract
 * @dev A company can issue assets and add experiences to worlds. This is the company logic 
 * implementation. All companies are fronted by an EntityProxy. The company constructor 
 * sets up immutable references to various registries for logic implementation.
 */
contract Company is BaseRemovableEntity, ICompany {

    using LibVectorAddress for VectorAddress;
    
    ICompanyRegistry public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IAssetRegistry public immutable erc20Registry;
    IAssetRegistry public immutable erc721Registry;
    IAvatarRegistry public immutable avatarRegistry;


    modifier onlyIfActive {
        require(LibRemovableEntity.load().active, 'Company: Company is not active');
        require(IWorld(LibRemovableEntity.load().termsOwner).isEntityActive(), 'Company: World is not active');
        _;
    }

    /**
     * 
     */
    constructor(CompanyConstructorArgs memory args) {
        require(args.companyRegistry != address(0), 'Company: Invalid company registry');
        require(args.experienceRegistry != address(0), 'Company: Invalid experience registry');
        require(args.erc20Registry != address(0), 'Company: Invalid erc20 registry');
        require(args.erc721Registry != address(0), 'Company: Invalid erc721 registry');
        require(args.avatarRegistry != address(0), 'Company: Invalid avatar registry');

        companyRegistry = ICompanyRegistry(args.companyRegistry);
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        erc20Registry = IAssetRegistry(args.erc20Registry);
        erc721Registry = IAssetRegistry(args.erc721Registry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
    }

    receive() external payable {}

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, 'Company: Insufficient balance');
        payable(msg.sender).transfer(amount);
    }

    function upgrade(bytes calldata initData) public onlyOwner nonReentrant {
        companyRegistry.upgradeEntity(initData);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    
    /**
     * @dev Initializes the company with the given information. This is called by the company registry
     * after cloning the company's proxy and assigning this logic to it.
     */
    function init(CompanyInitArgs memory args) public onlyRegistry {
        require(args.owner != address(0), 'Company: Invalid owner');
        require(args.world != address(0), 'Company: Invalid world');
        require(bytes(args.name).length > 0, 'Company: Invalid name');

        //true, false means we need a p value but not a p_sub value   
        args.vector.validate(true, false);
        
        //set the company name
        LibEntity.load().name = args.name;

        //initialize general removable entity storage
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = args.world;
        rs.vector = args.vector;

        //intialize access controls
        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);
    }

    function postUpgradeInit(bytes calldata) public override onlyRegistry {
        //no-op
    }

    /**
     * @dev Returns the address of the company registry
     */
    function owningRegistry() internal view override returns (address) {
        return address(companyRegistry);
    }
    
    /**
        * @dev Returns the address of the world in which the company operates.
     */
    function world() public view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    /**
     * @dev Returns the vector address of the company. The vector address is assigned by
     * the operating World.
     */
    function vectorAddress() public view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }

    /**
     * @dev Checks if this company can mint the given ERC20 asset. Only active companies can mint assets.
     */
    function canMintERC20(address asset, address to, uint256 amount) public view onlyIfActive returns (bool) {
        //check if asset is allowed
        //make sure asset is registered
        require(erc20Registry.isRegistered(asset), "Company: asset not registered");

        //make sure asset is active
        IERC20Asset mintable = IERC20Asset(asset);
        require(mintable.isEntityActive(), "Company: asset not active");

        //can only mint if company owns the asset
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        
        //and the asset allows to mint
        require(mintable.canMint(to, amount), "Company: cannot mint to address");

        //all checks passed
        return true;
    }

    /**
     * @dev Checks if this company can mint the given ERC721 asset. Only active companies can mint assets.
     */
    function canMintERC721(address asset, address to) public view onlyIfActive returns (bool) {
        //check if asset is allowed
        //make sure asset is registered
        require(erc721Registry.isRegistered(asset), "Company: asset not registered");

        //make sure asset is active
        IERC721Asset mintable = IERC721Asset(asset);
        require(mintable.isEntityActive(), "Company: asset not active");

        //can only mint if company owns the asset
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        
        //and the asset allows to mint
        require(mintable.canMint(to), "Company: cannot mint to address");

        //all checks passed
        return true;
    }

    /**
     * @dev Mints the given ERC20 asset to the given address. This can only be called by a company
     * signer and only if the company is active.
     */
    function mintERC20(address asset, address to, uint256 amount) public nonReentrant onlySigner {
        require(canMintERC20(asset, to, amount), "Company: cannot mint asset");
        IERC20Asset(asset).mint(to, amount);
    }

    /**
     * @dev Mints the given ERC721 asset to the given address. This can only be called by a company
     * signer and only if the company is active.
     */
    function mintERC721(address asset, address to) public nonReentrant onlySigner {
        require(canMintERC721(asset, to), "Company: cannot mint asset");
        IERC721Asset(asset).mint(to);
    }

    /**
     * @dev Revokes the given ERC20 asset from the given address. This can only be called by a company
     * signer and only if the company is active.
     */
    function revokeERC20(address asset, address holder, uint256 amount) public nonReentrant onlySigner onlyIfActive {
       //make sure the asset is registered. It doesn't have to be active to be revoked
        require(erc20Registry.isRegistered(asset), "Company: asset not registered");
        IERC20Asset mintable = IERC20Asset(asset);

        mintable.revoke(holder, amount);
    }

    function upgradeERC20(address asset, bytes calldata initData) public nonReentrant onlyAdmin onlyIfActive {
        require(erc20Registry.isRegistered(asset), "Company: asset not registered");
        IERC20Asset a = IERC20Asset(asset);
        require(a.issuer() == address(this), "Company: not issuer of asset");
        a.upgrade(initData);
    }

    /**
     * @dev Revokes the given ERC721 asset from the given address. This can only be called by a company
     * signer and only if the company is active.
     */
    function revokeERC721(address asset, address holder, uint256 tokenId) public nonReentrant onlySigner onlyIfActive {
       //make sure the asset is registered. It doesn't have to be active to be revoked
        require(erc721Registry.isRegistered(asset), "Company: asset not registered");
        IERC721Asset mintable = IERC721Asset(asset);

        mintable.revoke(holder, tokenId);
    }

    function upgradeERC721(address asset, bytes calldata initData) public nonReentrant onlyAdmin onlyIfActive {
        require(erc721Registry.isRegistered(asset), "Company: asset not registered");
        IERC721Asset a = IERC721Asset(asset);
        require(a.issuer() == address(this), "Company: not issuer of asset");
        a.upgrade(initData);
    }

    /**
        * @dev Sets the base URI for an ERC721 asset minted by this company. This can only be called by admins
     */
    function setERC721BaseURI(address asset, string calldata uri) public nonReentrant onlyAdmin {
        require(erc721Registry.isRegistered(asset), "Company: asset not registered");
        IERC721Asset e = IERC721Asset(asset);
        require(e.isEntityActive(), "Company: asset not active");
        e.setBaseURI(uri);
    }

    /**
     * @dev Adds an experience to the parent world. This also creates a portal into the 
     * experience and registers it in the PortalRegistry.
     */
    function addExperience(AddExperienceArgs memory args) public nonReentrant onlyAdmin returns (address experience, uint256 portalId) {
        
        //use the company's vector as a starting point
        VectorAddress memory sub = vectorAddress();

        CompanyStorage storage cs = LibCompany.load();

        //increment the sub-plane counter for this company
        ++cs.nextPSubValue;

        //assign it to the copied vector
        sub.p_sub = cs.nextPSubValue;

        //create the experience through our parent world. This is mostly so simplify off-chain
        //data indexing for all parties. Otherwise, world owners would have to monitor every
        //company contract they regsitered for experience updates.
        NewExperienceArgs memory expArgs = NewExperienceArgs({
            vector: sub,
            name: args.name,
            initData: args.initData
        });
        IWorld w = IWorld(world());
        (experience, portalId) = w.addExperience(expArgs);
        emit CompanyAddedExperience(experience, portalId);
    }

    /**
     * @dev Deactivates an experience. This can only be called by company admin
     */
    function deactivateExperience(address experience, string calldata reason) public nonReentrant onlyAdmin {
        //ask the world to deactivate
        IWorld(world()).deactivateExperience(experience, reason);
        emit CompanyDeactivatedExperience(experience, reason);
    }

    /**
     * @dev Reactivates an experience. This can only be called by company admin
     */
    function reactivateExperience(address experience) public nonReentrant onlyAdmin {
        IWorld(world()).reactivateExperience(experience);
        emit CompanyReactivatedExperience(experience);
    }

    /**
     * @dev Removes an experience from the world. This also removes the portal into the 
     * experience and unregisters it from the PortalRegistry. This can only be called
     * by company admin
     */
    function removeExperience(address experience, string calldata reason) public nonReentrant onlyAdmin {
        uint256 portalId = IWorld(world()).removeExperience(experience, reason);
        emit CompanyRemovedExperience(experience, reason, portalId);
    }

    function upgradeExperience(address exp, bytes calldata initData) public nonReentrant onlyAdmin onlyIfActive {
        require(experienceRegistry.isRegistered(exp), 'Company: Experience not registered');
        IExperience e = IExperience(exp);
        require(e.company() == address(this), 'Company: Experience does not belong to company');
        e.upgrade(initData);
    }

    /**
     * @dev Adds an experience condition to an experience. Going through the company
     * contract provides the necessary authorization checks and that only the experience
     * owner can add conditions.
     */
    function addExperienceCondition(address experience, address condition) public nonReentrant onlyAdmin {
        require(IExperience(experience).company() == address(this), 'Company: Experience does not belong to company');
        IExperience(experience).addPortalCondition(condition);
    }


    /**
     * @dev Removes an experience condition from an experience
     */
    function removeExperienceCondition(address experience) public nonReentrant onlyAdmin {
        require(IExperience(experience).company() == address(this), 'Company: Experience does not belong to company');
        IExperience(experience).removePortalCondition();
    }

    /**
     * @dev Changes the fee associated with a portal to an experience owned by the company.
     * Going through the company provides appropriate authorization checks.
     */
    function changeExperiencePortalFee(address experience, uint256 fee) public nonReentrant onlyAdmin {
        IExperience(experience).changePortalFee(fee);
    }

    /**
     * @dev Adds an asset condition to an asset. Going through the company
     * contract provides the necessary authorization checks and that only the asset
     * issuer can add conditions.
     */
    function addAssetCondition(address asset, address condition) public nonReentrant onlyAdmin {
        IAsset(asset).setCondition(condition);
    }

    /**
     * @dev Removes an asset condition from an asset
     */
    function removeAssetCondition(address asset) public nonReentrant onlyAdmin {
        IAsset(asset).removeCondition();
    }

    /**
     * @dev Delegates a jump for an avatar to the company. This allows the company to
     * pay the transaction fee but charge the avatar owner for the jump. This is useful
     * for companies that want to offer free jumps to avatars but charge them for the
     * experience.
     */
    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) public nonReentrant onlySigner {
        IAvatar avatar = IAvatar(request.avatar);
        //go through avatar contract to make the jump so that it pays the fee
        avatar.delegateJump(DelegatedJumpRequest({
            portalId: request.portalId,
            agreedFee: request.agreedFee,
            avatarOwnerSignature: request.avatarOwnerSignature
        }));
        emit ICompany.CompanyJumpedForAvatar(request.avatar, request.portalId, request.agreedFee);
    }
}
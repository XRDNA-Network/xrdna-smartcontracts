// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {ICompany, AddExperienceArgs, DelegatedAvatarJumpRequest} from './ICompany.sol';
import {IExperienceRegistry} from '../../experience/registry/IExperienceRegistry.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {CompanyStorage, LibCompany} from './LibCompany.sol';
import {IWorld, NewExperienceArgs} from '../../world/instance/IWorld.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {IAssetRegistry} from '../../asset/registry/IAssetRegistry.sol';
import {IMintableAsset} from '../../asset/instance/IMintableAsset.sol';
import {IAvatarRegistry} from '../../avatar/registry/IAvatarRegistry.sol';
import {IAvatar, DelegatedJumpRequest} from '../../avatar/instance/IAvatar.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {IAsset} from '../../asset/instance/IAsset.sol';

struct CompanyConstructorArgs {
    address companyRegistry;
    address experienceRegistry;
    address erc20Registry;
    address erc721Registry;
    address avatarRegistry;
}

contract Company is BaseRemovableEntity, ICompany {
    
    address public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IAssetRegistry public erc20Registry;
    IAssetRegistry public erc721Registry;
    IAvatarRegistry public avatarRegistry;


    modifier onlyIfActive {
        require(LibRemovableEntity.load().active, 'Company: Company is not active');
        _;
    }

    constructor(CompanyConstructorArgs memory args) {
        require(args.companyRegistry != address(0), 'Company: Invalid company registry');
        require(args.experienceRegistry != address(0), 'Company: Invalid experience registry');
        require(args.erc20Registry != address(0), 'Company: Invalid erc20 registry');
        require(args.erc721Registry != address(0), 'Company: Invalid erc721 registry');
        require(args.avatarRegistry != address(0), 'Company: Invalid avatar registry');

        companyRegistry = args.companyRegistry;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
        erc20Registry = IAssetRegistry(args.erc20Registry);
        erc721Registry = IAssetRegistry(args.erc721Registry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    
    function init(string calldata name, address _owner, address _world, VectorAddress calldata vector, bytes calldata) public onlyRegistry {
        require(_owner != address(0), 'Company: Invalid owner');
        require(_world != address(0), 'Company: Invalid world');
        
        LibEntity.load().name = name;   
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = _world;
        rs.vector = vector;
        address[] memory admins = new address[](0);
        LibAccess.initAccess(_owner, admins);
    }

    function owningRegistry() internal view override returns (address) {
        return companyRegistry;
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

    function canMintERC20(address asset, address to, bytes calldata extra) public view onlyIfActive returns (bool) {
        //check if asset is allowed
        return _canMint(erc20Registry, asset, to, extra);
    }

    function canMintERC721(address asset, address to, bytes calldata extra) public view onlyIfActive returns (bool) {
        //check if asset is allowed
        return _canMint(erc721Registry, asset, to, extra);
    }

    function mintERC20(address asset, address to, bytes calldata data) public onlySigner onlyIfActive {
        require(canMintERC20(asset, to, data), "Company: cannot mint asset");
        IMintableAsset(asset).mint(to, data);
    }

    function mintERC721(address asset, address to, bytes calldata data) public onlySigner onlyIfActive {
        require(canMintERC721(asset, to, data), "Company: cannot mint asset");
        IMintableAsset(asset).mint(to, data);
    }

    function revokeERC20(address asset, address holder, bytes calldata data) public onlySigner onlyIfActive {
        _revoke(erc20Registry, asset, holder, data);
    }

    function revokeERC721(address asset, address holder, bytes calldata data) public onlySigner onlyIfActive {
       _revoke(erc721Registry, asset, holder, data);
    }

    function _revoke(IAssetRegistry assetRegistry, address asset, address holder, bytes calldata data) internal {
        require(assetRegistry.isRegistered(asset), "Company: asset not registered");
        IMintableAsset mintable = IMintableAsset(asset);
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        mintable.revoke(holder, data);
    }

    function _canMint(IAssetRegistry assetRegistry, address asset, address to, bytes calldata extra) internal view returns (bool) {
        require(assetRegistry.isRegistered(asset), "Company: asset not registered");

        IMintableAsset mintable = IMintableAsset(asset);
        //can only mint if company owns the asset
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        
        //and the asset allows it
        require(mintable.canMint(to, extra), "Company: cannot mint to address");

        if(!avatarRegistry.isRegistered(to)) {
            return true;
        }

        //otherwise have to make sure avatar allows it if they are not in our experience
        IAvatar avatar = IAvatar(to);
        if(!avatar.canReceiveTokensOutsideOfExperience()) {
            address exp = avatar.location();
            require(exp != address(0), "Company: avatar location is not an experience");
            require(IExperience(exp).company() == address(this), "Company: avatar location is not in an experience owned by this company");
        }
        return true;
    }

    /**
     * @dev Adds an experience to the world. This also creates a portal into the 
     * experience and registers it in the PortalRegistry. It is assumed that the 
     * initialization data for the experience will include the expected fee
     * for the portal.
     */
    function addExperience(AddExperienceArgs memory args) public onlySigner returns (address experience, uint256 portalId) {
        VectorAddress memory sub = vectorAddress();
        CompanyStorage storage cs = LibCompany.load();
        ++cs.nextPSubValue;
        sub.p_sub = cs.nextPSubValue;
        NewExperienceArgs memory expArgs = NewExperienceArgs({
            vector: sub,
            name: args.name,
            initData: args.initData
        });
        IWorld w = IWorld(world());
        (experience, portalId) = w.addExperience(expArgs);
        emit CompanyAddedExperience(experience, portalId);
    }

    function deactiveExperience(address experience, string calldata reason) public onlySigner {
        IWorld(world()).deactivateExperience(experience, reason);
        emit CompanyDeactivatedExperience(experience, reason);
    }

    function reactivateExperience(address experience) public onlySigner {
        IWorld(world()).reactivateExperience(experience);
        emit CompanyReactivatedExperience(experience);
    }

    /**
     * @dev Removes an experience from the world. This also removes the portal into the 
     * experience and unregisters it from the PortalRegistry. This can only be called
     * by company admin
     */
    function removeExperience(address experience, string calldata reason) public onlySigner {
        uint256 portalId = IWorld(world()).removeExperience(experience, reason);
        emit CompanyRemovedExperience(experience, reason, portalId);
    }


    /**
     * @dev Withdraws the given amount of funds from the company. Only the owner can withdraw funds.
     */
    function withdraw(uint256 amount) public onlyOwner {
        require(amount >= address(this).balance, 'Company: Insufficient funds');
        payable(LibAccess.owner()).transfer(amount);
    }

    /**
     * @dev Adds an experience condition to an experience. Going through the company
     * contract provides the necessary authorization checks and that only the experience
     * owner can add conditions.
     */
    function addExperienceCondition(address experience, address condition) public onlyAdmin {
        require(IExperience(experience).company() == address(this), 'Company: Experience does not belong to company');
        IExperience(experience).addPortalCondition(condition);
    }


    /**
     * @dev Removes an experience condition from an experience
     */
    function removeExperienceCondition(address experience) public onlyAdmin {
        require(IExperience(experience).company() == address(this), 'Company: Experience does not belong to company');
        IExperience(experience).removePortalCondition();
    }

    /**
     * @dev Changes the fee associated with a portal to an experience owned by the company.
     * Going through the company provides appropriate authorization checks.
     */
    function changeExperiencePortalFee(address experience, uint256 fee) public onlyAdmin {
        IExperience(experience).changePortalFee(fee);
    }

    /**
     * @dev Adds an asset condition to an asset. Going through the company
     * contract provides the necessary authorization checks and that only the asset
     * issuer can add conditions.
     */
    function addAssetCondition(address asset, address condition) public onlyAdmin {
        IAsset(asset).setCondition(condition);
    }

    /**
     * @dev Removes an asset condition from an asset
     */
    function removeAssetCondition(address asset) public onlyAdmin {
        IAsset(asset).removeCondition();
    }

    /**
     * @dev Delegates a jump for an avatar to the company. This allows the company to
     * pay the transaction fee but charge the avatar owner for the jump. This is useful
     * for companies that want to offer free jumps to avatars but charge them for the
     * experience.
     */
    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) public onlySigner {
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
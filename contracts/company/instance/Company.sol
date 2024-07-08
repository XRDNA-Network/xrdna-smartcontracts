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


/**
 * @dev Arguments for initializing a company.
 */
struct CompanyInitArgs {
     //the address of the company owner
    address owner;
}

struct CompanyConstructorArgs {
    address companyRegistry;
    address experienceRegistry;
}

contract Company is BaseRemovableEntity, ICompany {
    
    address public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;


    constructor(CompanyConstructorArgs memory args) {
        require(args.companyRegistry != address(0), 'Company: Invalid company registry');
        require(args.experienceRegistry != address(0), 'Company: Invalid experience registry');
        companyRegistry = args.companyRegistry;
        experienceRegistry = IExperienceRegistry(args.experienceRegistry);
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    
    function init(string calldata name, address _world, VectorAddress calldata vector, bytes calldata initData) public onlyRegistry {
        LibEntity.load().name = name;   
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = _world;
        rs.vector = vector;
        CompanyInitArgs memory args = abi.decode(initData, (CompanyInitArgs));
        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);
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

    /**
     * @dev Returns whether this company can mint the given asset to the given address.
     * The data parameter is dependent on the type of asset.
     */
    function canMintERC20(address asset, address to, bytes calldata data) public view returns (bool) {
        return false;
    }
    
    function canMintERC721(address asset, address to, bytes calldata data) public view returns (bool) {
        return false;
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
     * @dev Check whether this company owns the experience attached to the given portal id
     */
    function companyOwnsDestinationPortal(uint256 portalId) public view returns (bool) {
        return false;
    }

    /**
     * @dev Mints the given amount of the given asset to the given address. The data
     * parameter is dependent on the type of asset.
     */
    function mintERC20(address asset, address to, bytes calldata data) public onlySigner {

    }

    function mintERC721(address asset, address to, bytes calldata data) public onlySigner {

    }

    /**
     * @dev Revokes the given amount of the given asset from the given address. The data
     * parameter is dependent on the type of asset. This is likely called when an avatar
     * owner transfers the original asset on another chain (i.e. all assets in the 
     * interoperability layer are synthetic assets that represent assets on other chains).
     */
    function revokeERC20(address asset, address holder, bytes calldata data) public onlySigner {

    }

    function revokeERC721(address asset, address holder, bytes calldata data) public onlySigner {

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

    }


    /**
     * @dev Removes an experience condition from an experience
     */
    function removeExperienceCondition(address experience) public onlyAdmin {

    }

    /**
     * @dev Changes the fee associated with a portal to an experience owned by the company.
     * Going through the company provides appropriate authorization checks.
     */
    function changeExperiencePortalFee(address experience, uint256 fee) public onlyAdmin {

    }

    /**
     * @dev Adds an asset condition to an asset. Going through the company
     * contract provides the necessary authorization checks and that only the asset
     * issuer can add conditions.
     */
    function addAssetCondition(address asset, address condition) public onlyAdmin {

    }

    /**
     * @dev Removes an asset condition from an asset
     */
    function removeAssetCondition(address asset) public onlyAdmin {

    }

    /**
     * @dev Delegates a jump for an avatar to the company. This allows the company to
     * pay the transaction fee but charge the avatar owner for the jump. This is useful
     * for companies that want to offer free jumps to avatars but charge them for the
     * experience.
     */
    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) public onlySigner {

    }
}
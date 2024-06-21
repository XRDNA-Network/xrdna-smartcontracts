// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {ICompany, AddExperienceArgs, CompanyInitArgs, DelegatedAvatarJumpRequest} from '../company/ICompany.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {IAvatarRegistry} from '../avatar/IAvatarRegistry.sol';
import {IExperienceRegistry, RegisterExperienceRequest} from '../experience/IExperienceRegistry.sol';
import {IMultiAssetRegistry} from '../asset/IMultiAssetRegistry.sol';
import {IExperience} from '../experience/IExperience.sol';
import {IAvatar, DelegatedJumpRequest} from '../avatar/IAvatar.sol';
import {ICompanyRegistry} from './ICompanyRegistry.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {ICompanyHook} from './ICompanyHook.sol';
import {IPortalCondition} from '../portal/IPortalCondition.sol';
import {IAssetHook} from '../asset/IAssetHook.sol';
import {CompanyV1Storage, LibCompanyV1Storage} from '../libraries/LibCompanyV1Storage.sol';
import {BaseProxyStorage, LibBaseProxy, LibProxyAccess} from '../libraries/LibBaseProxy.sol';
import {IBasicAsset} from '../asset/IBasicAsset.sol';
import {BaseAccess} from '../BaseAccess.sol';
import {IMintableAsset} from '../asset/IMintableAsset.sol';
import {IAssetCondition} from '../asset/IAssetCondition.sol';
import {IWorld} from '../world/IWorld.sol';
import {IPortalRegistry, PortalInfo} from '../portal/IPortalRegistry.sol';
import {HookStorage, LibHooks} from '../libraries/LibHooks.sol';
import {BaseHookSupport} from '../BaseHookSupport.sol';

//constructor arguments for master copy of Company
struct CompanyConstructorArgs {
    address companyFactory;
    address companyRegistry;
    IExperienceRegistry experienceRegistry;
    IMultiAssetRegistry multiAssetRegistry;
    IAvatarRegistry avatarRegistry;
}

/**
 * @title Company
 * @dev A company that can add experiences to a world and mint assets.
 */
contract Company is ICompany, BaseAccess, BaseHookSupport, ReentrancyGuard {
    using LibProxyAccess for BaseProxyStorage;
    using LibHooks for HookStorage;

    //Fields initialized for master copy of company
    address public immutable companyFactory;
    ICompanyRegistry public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IMultiAssetRegistry public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;

    //version of this company implementation
    uint256 public constant override version = 1;


    modifier onlyFactory {
        require(companyFactory != address(0), "Company: factory not set");
        require(msg.sender == companyFactory, "Company: caller is not the factory");
        _;
    }

    modifier onlyRegistry {
        require(address(companyRegistry) != address(0), "Company: registry not set");
        require(msg.sender == address(companyRegistry), "Company: caller is not the registry");
        _;
    }

    modifier onlyActive {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        require(s.active, "Company: company is not active");
        _;
    }

    constructor(CompanyConstructorArgs memory args) {
        require(args.companyFactory != address(0), "Company: companyFactory cannot be 0x0");
        require(args.companyRegistry != address(0), "Company: companyRegistry cannot be 0x0");
        require(address(args.experienceRegistry) != address(0), "Company: experienceRegistry cannot be 0x0");
        require(address(args.multiAssetRegistry) != address(0), "Company: assetRegistry cannot be 0x0");
        require(address(args.avatarRegistry) != address(0), "Company: avatarRegistry cannot be 0x0");
        companyFactory = args.companyFactory;
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        experienceRegistry = args.experienceRegistry;
        assetRegistry = args.multiAssetRegistry;
        avatarRegistry = args.avatarRegistry;
    }

    //Funds are transferred to company contract so must be able to receive
    receive() external payable {}


    /**
     * @inheritdoc ICompany
     */
    function init(CompanyInitArgs memory request) public onlyFactory {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        require(s.owner == address(0), "Company: already initialized");
        require(request.owner != address(0), "Company: owner cannot be 0x0");

        /**
        * WARN: there is an issue with unicode or whitespace characters present in names. 
        * Off-chain verification should ensure that names are properly trimmed and
        * filtered with hidden characters if we truly want visually-unique names.
        */
        require(bytes(request.name).length > 0, "Company: name cannot be empty");
        require(request.world != address(0), "Company: world cannot be 0x0");
        s.owner = request.owner;
        s.world = request.world;
        s.vectorAddress = request.vector;
        s.name = request.name;
        s.active = true;

        BaseProxyStorage storage ps = LibBaseProxy.load();
        ps.grantRole(LibProxyAccess.ADMIN_ROLE, request.owner);
        ps.grantRole(LibProxyAccess.SIGNER_ROLE, request.owner);
    }

    function isAdmin(address account) internal override view returns (bool) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return account == s.owner;
    }

    /**
     * @inheritdoc ICompany
     */
    function deactivate() external onlyRegistry {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        s.active = false;
        if(address(this).balance > 0) {
            payable(s.owner).transfer(address(this).balance);
        }
        emit CompanyDeactivated();
    }

    /**
     * @inheritdoc ICompany
     */
    function reactivate() external payable onlyRegistry {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        s.active = true;
        emit CompanyReactivated();
    }

    /**
        * @inheritdoc ICompany
     */
     function isActive() external view override returns (bool) {
         CompanyV1Storage storage s = LibCompanyV1Storage.load();
         return s.active;
     }

    /**
        * @inheritdoc ICompany
     */
    function owner() external view returns (address) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.owner;
    }

    /**
        * @inheritdoc ICompany
     */
    function name() external view returns (string memory) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.name;
    }

    /**
        * @inheritdoc ICompany
     */
    function world() external view returns (address) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.world;
    }

    /**
        * @inheritdoc ICompany
     */
    function vectorAddress() external view returns (VectorAddress memory) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.vectorAddress;
    }
    
    /**
     * @inheritdoc ICompany
     */
    function canMint(address asset, address to, bytes calldata extra) public view onlyActive returns (bool) {
        //check if asset is allowed
        require(assetRegistry.isRegisteredAsset(asset), "Company: asset not registered");

        IMintableAsset mintable = IMintableAsset(asset);
        //can only mint if company owns the asset
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        
        //and the asset allows it
        require(mintable.canMint(to, extra), "Company: cannot mint to address");

        //if not an avatar, we can mint
        if(!avatarRegistry.isAvatar(to)) {
            return true;
        }

        //otherwise have to make sure avatar allows it if they are not in our experience
        IAvatar avatar = IAvatar(to);
        if(!avatar.canReceiveTokensOutsideOfExperience()) {
            IExperience exp = avatar.location();
            require(address(exp) != address(0), "Company: avatar location is not an experience");
            require(exp.company() == address(this), "Company: avatar location is not in an experience owned by this company");
        }
        return true;
    }

    //convenience function to encode AddExperienceArgs
    function encodeExperienceArgs(AddExperienceArgs memory args) public pure returns (bytes memory) {
        return abi.encode(args);
    }

    /**
        * @inheritdoc ICompany
     */
    function addExperience(AddExperienceArgs memory args) external onlySigner onlyActive nonReentrant {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        ++s.nextPsub;
        VectorAddress memory expVector = VectorAddress({
            x: s.vectorAddress.x,
            y: s.vectorAddress.y,
            z: s.vectorAddress.z,
            t: s.vectorAddress.t,
            p: s.vectorAddress.p,
            p_sub: s.nextPsub
        });
        RegisterExperienceRequest memory req = RegisterExperienceRequest({
            company: address(this),
            name: args.name,
            vector: expVector,
            initData: args.initData
        });
        (address exp, uint256 portalId) = IWorld(s.world).registerExperience(req);
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeAddExperience(args), "Company: beforeAddExperience hook failed");
        }
        emit CompanyAddedExperience(exp, portalId);
    }

    /**
        * @inheritdoc ICompany
     */
    function removeExperience(address experience) public onlyAdmin onlyActive nonReentrant {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        uint256 portalId = IWorld(s.world).deactivateExperience(experience);
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRemoveExperience(experience), "Company: beforeRemoveExperience hook failed");
        }
        emit CompanyRemovedExperience(experience, portalId);
    }

    /**
        * @inheritdoc ICompany
     */
    function mint(address asset, address to, bytes calldata data) public onlySigner onlyActive nonReentrant {
        require(canMint(asset, to, data), "Company: cannot mint asset");
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeMint(asset, to, data), "Company: beforeMint hook failed");
        }

        IMintableAsset(asset).mint(to, data);
    }

    /**
        * @inheritdoc ICompany
     */
    function revoke(address asset, address holder, bytes calldata data) public onlySigner onlyActive nonReentrant {
        require(assetRegistry.isRegisteredAsset(asset), "Company: asset not registered");
        IMintableAsset mintable = IMintableAsset(asset);
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRevoke(asset, holder, data), "Company: beforeRevoke hook failed");
        }
        mintable.revoke(holder, data);
    }

    /**
        * @inheritdoc ICompany
     */
    function upgrade(bytes memory initData) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeUpgrade(initData), "Company: beforeUpgrade hook failed");
        }
        companyRegistry.upgradeCompany(initData);
    }

    /**
        * @inheritdoc ICompany
     */
    function upgradeComplete(address nextVersion) public onlyFactory {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        address old = bs.implementation;
        bs.implementation = nextVersion;
        emit CompanyUpgraded(old, nextVersion);
    }

    /**
        * @inheritdoc ICompany
     */
    function withdraw (uint256 amount) public onlyAdmin onlyActive {
        require(amount <= address(this).balance, "Company: insufficient balance");
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        payable(s.owner).transfer(amount);
    }

    /**
        * @inheritdoc ICompany
     */
    function addExperienceCondition(address experience, address condition) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeAddPortalCondition(experience, condition), "Company: beforeAddPortalCondition hook failed");
        }
        IExperience exp = IExperience(experience);
        exp.addPortalCondition(IPortalCondition(condition));
        emit CompanyAddedExperienceCondition(experience, condition);
    }

    /**
        * @inheritdoc ICompany
     */
    function removeExperienceCondition(address experience) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRemovePortalCondition(experience), "Company: beforeRemovePortalCondition hook failed");
        }
        IExperience exp = IExperience(experience);
        exp.removePortalCondition();
        emit CompanyRemovedExperienceCondition(experience);
    }

    /**
        * @inheritdoc ICompany
     */
    function changeExperiencePortalFee(address experience, uint256 fee) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeChangePortalFees(fee), "Company: beforeChangePortalFees hook failed");
        }
        IExperience exp = IExperience(experience);
        exp.changePortalFee(fee);
        emit CompanyChangedExperiencePortalFee(experience, fee);
    }

    /**
        * @inheritdoc ICompany
     */
    function addAssetHook(address asset, IAssetHook aHook) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeAddAssetHook(asset, address(aHook)), "Company: beforeAddAssetHook hook failed");
        }
        IBasicAsset(asset).setHook(address(aHook));
        emit CompanyAddedAssetHook(asset, address(aHook));
    }

    /**
        * @inheritdoc ICompany
     */
    function removeAssetHook(address asset) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRemoveAssetHook(asset), "Company: beforeRemoveAssetHook hook failed");
        }
        IBasicAsset(asset).removeHook();
        emit CompanyRemovedAssetHook(asset);
    }

    /**
        * @inheritdoc ICompany
     */
    function addAssetCondition(address asset, address condition) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeAddAssetCondition(asset, condition), "Company: beforeAddAssetCondition hook failed");
        }
        IBasicAsset(asset).addCondition(IAssetCondition(condition));
        emit CompanyAddedAssetCondition(asset, condition);
    }

    /**
        * @inheritdoc ICompany
     */
    function removeAssetCondition(address asset) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRemoveAssetCondition(asset), "Company: beforeRemoveAssetCondition hook failed");
        }
        IBasicAsset(asset).removeCondition();
        emit CompanyRemovedAssetCondition(asset);
    }

    /**
        * @inheritdoc ICompany
     */
    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) public override onlySigner onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeDelegatedJump(request.avatar, request.portalId, request.agreedFee), "Company: beforeDelegatedJump hook failed");
        }
        IAvatar avatar = IAvatar(request.avatar);
        //go through avatar contract to make the jump so that it pays the fee
        avatar.delegateJump(DelegatedJumpRequest({
            portalId: request.portalId,
            agreedFee: request.agreedFee,
            avatarOwnerSignature: request.avatarOwnerSignature
        }));
        emit CompanyJumpedForAvatar(request.avatar, request.portalId, request.agreedFee);
    }

    /**
        * @inheritdoc ICompany
     */
    function upgradeExperience(address experience, bytes memory initData) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeUpgradeExperience(experience, initData), "Company: beforeUpgradeExperience hook failed");
        }
        IExperience exp = IExperience(experience);
        address next = exp.upgrade(initData);
        emit CompanyUpgradedExperience(experience, next);
    }

    /**
        * @inheritdoc ICompany
     */
    function upgradeAsset(address asset, bytes memory initData) public onlyAdmin onlyActive {
        ICompanyHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeUpgradeAsset(asset, initData), "Company: beforeUpgradeAsset hook failed");
        }
        address next = IMintableAsset(asset).upgrade(initData);
        emit CompanyUpgradedAsset(asset, next);
    }

    function companyOwnsDestinationPortal(uint256 portalId) public view returns (bool) {
        IPortalRegistry reg = experienceRegistry.portalRegistry();
        PortalInfo memory info = reg.getPortalInfoById(portalId);
        require(address(info.destination) != address(0), "Company: portal does not exist");
        return info.destination.company() == address(this);
    }

    function _getHook() internal view returns (ICompanyHook) {
        return ICompanyHook(LibHooks.load().getHook());
    }
}
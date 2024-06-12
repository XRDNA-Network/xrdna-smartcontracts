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

struct CompanyConstructorArgs {
    address companyFactory;
    address companyRegistry;
    IExperienceRegistry experienceRegistry;
    IMultiAssetRegistry multiAssetRegistry;
    IAvatarRegistry avatarRegistry;
}


interface INextVersion {
    function setStartingPSub(uint256 psub) external;
}

contract Company is ICompany, BaseAccess, ReentrancyGuard {
    using LibProxyAccess for BaseProxyStorage;

    //Fields initialized at deployment time
    address public immutable companyFactory;
    ICompanyRegistry public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IMultiAssetRegistry public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;
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

    receive() external payable {}

    function init(CompanyInitArgs memory request) public onlyFactory {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        require(s.owner == address(0), "Company: already initialized");
        require(request.owner != address(0), "Company: owner cannot be 0x0");
        require(bytes(request.name).length > 0, "Company: name cannot be empty");
        require(request.world != address(0), "Company: world cannot be 0x0");
        s.owner = request.owner;
        s.world = request.world;
        s.vectorAddress = request.vector;
        s.name = request.name;

        BaseProxyStorage storage ps = LibBaseProxy.load();
        ps.grantRole(LibProxyAccess.ADMIN_ROLE, request.owner);
        ps.grantRole(LibProxyAccess.SIGNER_ROLE, request.owner);
    }

    function owner() external view returns (address) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.owner;
    }

    function name() external view returns (string memory) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.name;
    }

    function world() external view returns (address) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.world;
    }

    function vectorAddress() external view returns (VectorAddress memory) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.vectorAddress;
    }
    
    function canMint(address asset, address to, bytes calldata extra) public view returns (bool) {
        
        require(assetRegistry.isRegisteredAsset(asset), "Company: asset not registered");

        IMintableAsset mintable = IMintableAsset(asset);
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        
        require(mintable.canMint(to, extra), "Company: cannot mint to address");

        if(!avatarRegistry.isAvatar(to)) {
            return true;
        }

        IAvatar avatar = IAvatar(to);
        if(!avatar.canReceiveTokensOutsideOfExperience()) {
            IExperience exp = avatar.location();
            require(address(exp) != address(0), "Company: avatar location is not an experience");
            require(exp.company() == address(this), "Company: avatar location is not in an experience owned by this company");
        }
        return true;
    }

    function encodeExperienceArgs(AddExperienceArgs memory args) public pure returns (bytes memory) {
        return abi.encode(args);
    }

    function addExperience(AddExperienceArgs memory args) external onlySigner nonReentrant {
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
            name: args.name,
            vector: expVector,
            initData: args.initData
        });
        (address exp, uint256 portalId) = experienceRegistry.registerExperience(req);
        emit ExperienceAdded(exp, portalId);
        
    }
    function mint(address asset, address to, bytes calldata data) public onlySigner nonReentrant {
        require(canMint(asset, to, data), "Company: cannot mint asset");
        
        IMintableAsset(asset).mint(to, data);
    }

    function revoke(address asset, address holder, bytes calldata data) public onlySigner nonReentrant {
        require(assetRegistry.isRegisteredAsset(asset), "Company: asset not registered");
        IMintableAsset mintable = IMintableAsset(asset);
        require(mintable.issuer() == address(this), "Company: not issuer of asset");
        mintable.revoke(holder, data);
    }

    function upgrade(bytes memory initData) public onlyAdmin {
        companyRegistry.upgradeCompany(initData);
    }

    function upgradeComplete(address nextVersion) public onlyFactory {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        address old = bs.implementation;
        bs.implementation = nextVersion;
        emit CompanyUpgraded(old, nextVersion);
    }

    function withdraw (uint256 amount) public onlyAdmin {
        require(amount <= address(this).balance, "Company: insufficient balance");
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        payable(s.owner).transfer(amount);
    }

    function setHook(ICompanyHook _hook) public onlyAdmin {
        require(address(_hook) != address(0), "Company: hook cannot be 0x0");
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        s.hook = _hook;
    }
    
    function removeHook() public onlyAdmin {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        s.hook = ICompanyHook(address(0));
    }

    function addExperienceCondition(address experience, address condition) public onlyAdmin {
        IExperience exp = IExperience(experience);
        exp.addPortalCondition(IPortalCondition(condition));
    }

    function removeExperienceCondition(address experience) public onlyAdmin {
        IExperience exp = IExperience(experience);
        exp.removePortalCondition();
    }

    function changeExperiencePortalFee(address experience, uint256 fee) public onlyAdmin {
        IExperience exp = IExperience(experience);
        exp.changePortalFee(fee);
    }

    function addAssetHook(address asset, IAssetHook aHook) public onlyAdmin {
        IBasicAsset(asset).addHook(aHook);
    }

    function removeAssetHook(address asset) public onlyAdmin {
        IBasicAsset(asset).removeHook();
    }

    function addAssetCondition(address asset, address condition) public onlyAdmin {
        IBasicAsset(asset).addCondition(IAssetCondition(condition));
    }

    function removeAssetCondition(address asset) public onlyAdmin {
        IBasicAsset(asset).removeCondition();
    }

    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) public override onlySigner {
        IAvatar avatar = IAvatar(request.avatar);
        avatar.delegateJump(DelegatedJumpRequest({
            portalId: request.portalId,
            agreedFee: request.agreedFee,
            avatarOwnerSignature: request.avatarOwnerSignature
        }));
    }
}
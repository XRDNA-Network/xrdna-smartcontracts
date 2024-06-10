// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {ICompany, AddExperienceArgs, CompanyInitArgs} from '../company/ICompany.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {VectorAddress} from '../VectorAddress.sol';
import {AssetType} from '../asset/AssetFactory.sol';
import {IAvatarRegistry} from '../avatar/IAvatarRegistry.sol';
import {IExperienceRegistry, RegisterExperienceRequest} from '../experience/IExperienceRegistry.sol';
import {IAssetRegistry} from '../asset/IAssetRegistry.sol';
import {IExperience} from '../experience/IExperience.sol';
import {IAvatar} from '../avatar/IAvatar.sol';
import {IERC20Asset} from '../asset/IERC20Asset.sol';
import {IERC721Asset} from '../asset/IERC721Asset.sol';
import {ICompanyRegistry} from './ICompanyRegistry.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {ICompanyHook} from './ICompanyHook.sol';
import {IPortalCondition} from '../portal/IPortalCondition.sol';
import {IAssetHook} from '../asset/IAssetHook.sol';
import {CompanyV1Storage, LibCompanyV1Storage} from '../libraries/LibCompanyV1Storage.sol';
import {BaseProxyStorage, LibBaseProxy, LibProxyAccess} from '../libraries/LibBaseProxy.sol';
import {IBasicAsset} from '../asset/IBasicAsset.sol';

struct CompanyConstructorArgs {
    address companyFactory;
    address companyRegistry;
    IExperienceRegistry experienceRegistry;
    IAssetRegistry assetRegistry;
    IAvatarRegistry avatarRegistry;
}


interface INextVersion {
    function setStartingPSub(uint256 psub) external;
}

contract Company is ICompany, ReentrancyGuard {
    using LibProxyAccess for BaseProxyStorage;

    //Fields initialized at deployment time
    address public immutable companyFactory;
    ICompanyRegistry public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IAssetRegistry public immutable assetRegistry;
    IAvatarRegistry public immutable avatarRegistry;
    uint256 public constant override version = 1;


    

    modifier notUpgraded {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        require(!s.upgraded, "Company: contract has been upgraded");
        _;
    }

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

    modifier onlyAdmin {
        BaseProxyStorage storage ps = LibBaseProxy.load();
        require(ps.hasRole(LibProxyAccess.ADMIN_ROLE, msg.sender), "Company: caller is not an admin");
        _;
    }

    modifier onlySigner {
        BaseProxyStorage storage ps = LibBaseProxy.load();
        require(ps.hasRole(LibProxyAccess.SIGNER_ROLE, msg.sender), "Company: caller is not a signer");
        _;
    }

    constructor(CompanyConstructorArgs memory args) {
        require(args.companyFactory != address(0), "Company: companyFactory cannot be 0x0");
        require(args.companyRegistry != address(0), "Company: companyRegistry cannot be 0x0");
        require(address(args.experienceRegistry) != address(0), "Company: experienceRegistry cannot be 0x0");
        require(address(args.assetRegistry) != address(0), "Company: assetRegistry cannot be 0x0");
        require(address(args.avatarRegistry) != address(0), "Company: avatarRegistry cannot be 0x0");
        companyFactory = args.companyFactory;
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        experienceRegistry = args.experienceRegistry;
        assetRegistry = args.assetRegistry;
        avatarRegistry = args.avatarRegistry;
    }

    receive() external payable {}


    function upgraded() external view override returns (bool) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.upgraded;
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
        ps.setRole(LibProxyAccess.ADMIN_ROLE, request.owner, true);
        ps.setRole(LibProxyAccess.SIGNER_ROLE, request.owner, true);
    }

    function vectorAddress() external view returns (VectorAddress memory) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        return s.vectorAddress;
    }

    function isSigner(address signer) external view returns (bool) {
        BaseProxyStorage storage ps = LibBaseProxy.load();
        return ps.hasRole(LibProxyAccess.SIGNER_ROLE, signer);
    }

    function canMint(address asset, address to, uint256) public view returns (bool) {
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        if(s.upgraded) {
            return false;
        }

        if(!assetRegistry.isRegisteredAsset(asset)) {
            return false;
        }
        if(IBasicAsset(asset).issuer() != address(this)) {
            return false;
        }
        if(!avatarRegistry.isAvatar(to)) {
            return true;
        }
        IExperience exp = IAvatar(to).location();
        require(address(exp) != address(0), "Company: avatar location is not an experience");
        return exp.company() == address(this);
    }

    function addSigner(address signer) external onlyAdmin notUpgraded {
        require(signer != address(0), "Company: signer cannot be 0x0");
        BaseProxyStorage storage ps = LibBaseProxy.load();
        ps.setRole(LibProxyAccess.SIGNER_ROLE, signer, true);
        emit SignerAdded(signer);
    }

    function removeSigner(address signer) external onlyAdmin {
        require(signer != address(0), "Company: signer cannot be 0x0");
        BaseProxyStorage storage ps = LibBaseProxy.load();
        ps.setRole(LibProxyAccess.SIGNER_ROLE, signer, false);
        emit SignerRemoved(signer);
    }

    function encodeExperienceArgs(AddExperienceArgs memory args) public pure returns (bytes memory) {
        return abi.encode(args);
    }

    function addExperience(AddExperienceArgs memory args) external onlySigner notUpgraded nonReentrant {
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
    function mint(address asset, address to, uint256 amount) public onlySigner notUpgraded nonReentrant {
        require(canMint(asset, to, amount), "Company: cannot mint asset");
        
        AssetType at = AssetType(IBasicAsset(asset).assetType());
        if(at == AssetType.ERC20) {
            IERC20Asset(asset).mint(to, amount);
            emit AssetMinted(asset, to, amount);
        } else if(at == AssetType.ERC721) {
            uint256 tokenId = IERC721Asset(asset).mint(to);
            emit AssetMinted(asset, to, tokenId);
        } else {
            revert("Company: unsupported asset type");
        }
        
    }

    function revoke(address asset, address holder, uint256 amountOrTokenId) public onlySigner notUpgraded nonReentrant {
        AssetType at = AssetType(IBasicAsset(asset).assetType());
        if(at == AssetType.ERC20) {
            IERC20Asset(asset).revoke(holder, amountOrTokenId);
        } else if(at == AssetType.ERC721) {
            IERC721Asset(asset).revoke(amountOrTokenId);
        } else {
            revert("Company: unsupported asset type");
        }
        emit AssetRevoked(asset, holder, amountOrTokenId);
    }

    function upgrade(bytes memory initData) public onlyAdmin notUpgraded {
        
        CompanyV1Storage storage s = LibCompanyV1Storage.load();
        s.upgraded = true;
        companyRegistry.upgradeCompany(initData);
    }

    function upgradeComplete(address nextVersion) public onlyRegistry nonReentrant {
        BaseProxyStorage storage bs = LibBaseProxy.load();
        bs.implementation = nextVersion;
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
}
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

struct CompanyConstructorArgs {
    address companyFactory;
    address companyRegistry;
    IExperienceRegistry experienceRegistry;
    IAssetRegistry assetRegistry;
    IAvatarRegistry avatarRegistry;
}

interface IBaseAsset {
    function issuer() external view returns (address);
    function assetType () external view returns (uint256);
}

interface INextVersion {
    function setStartingPSub(uint256 psub) external;
}

contract Company is ICompany, ReentrancyGuard, AccessControl {

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    //Fields initialized at deployment time
    address public immutable companyFactory;
    ICompanyRegistry public immutable companyRegistry;
    IExperienceRegistry public immutable experienceRegistry;
    IAssetRegistry public immutable assetRegistry;
    IAvatarRegistry public avatarRegistry;


    //Fields initialized by initialize function
    bool public upgraded;
    address public override owner;
    address public override world;
    ICompanyHook public hook;
    VectorAddress _vectorAddress;
    string public override name;
    uint256 nextPsub;

    modifier notUpgraded {
        require(!upgraded, "Company: contract has been upgraded");
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

    function init(CompanyInitArgs memory request) public onlyFactory {
        require(owner == address(0), "Company: already initialized");
        require(request.owner != address(0), "Company: owner cannot be 0x0");
        require(bytes(request.name).length > 0, "Company: name cannot be empty");
        require(request.world != address(0), "Company: world cannot be 0x0");
        owner = request.owner;
        world = request.world;
        _vectorAddress = request.vector;
        name = request.name;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(SIGNER_ROLE, owner);
    }

    function vectorAddress() external view returns (VectorAddress memory) {
        return _vectorAddress;
    }

    function isSigner(address signer) external view returns (bool) {
        return hasRole(SIGNER_ROLE, signer);
    }

    function canMint(address asset, address to, uint256) public view returns (bool) {
        if(upgraded) {
            return false;
        }

        if(!assetRegistry.isRegisteredAsset(asset)) {
            return false;
        }
        if(IBaseAsset(asset).issuer() != address(this)) {
            return false;
        }
        if(!avatarRegistry.isAvatar(to)) {
            return true;
        }
        IExperience exp = IAvatar(to).location();
        require(address(exp) != address(0), "Company: avatar location is not an experience");
        return exp.company() == address(this);
    }

    function addSigner(address signer) external onlyRole(DEFAULT_ADMIN_ROLE) notUpgraded {
        require(signer != address(0), "Company: signer cannot be 0x0");
        _grantRole(SIGNER_ROLE, signer);
        emit SignerAdded(signer);
    }

    function removeSigner(address signer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(signer != address(0), "Company: signer cannot be 0x0");
        _revokeRole(SIGNER_ROLE, signer);
        emit SignerRemoved(signer);
    }

    function addExperience(AddExperienceArgs memory args) external onlyRole(SIGNER_ROLE) notUpgraded nonReentrant {
        ++nextPsub;
        VectorAddress memory expVector = VectorAddress({
            x: _vectorAddress.x,
            y: _vectorAddress.y,
            z: _vectorAddress.z,
            t: _vectorAddress.t,
            p: _vectorAddress.p,
            p_sub: nextPsub
        });
        RegisterExperienceRequest memory req = RegisterExperienceRequest({
            name: args.name,
            vector: expVector,
            initData: args.initData
        });
        (address exp, uint256 portalId) = experienceRegistry.registerExperience(req);
        emit ExperienceAdded(exp, portalId);
        
    }
    function mint(address asset, address to, uint256 amount) public onlyRole(SIGNER_ROLE) notUpgraded nonReentrant {
        require(canMint(asset, to, amount), "Company: cannot mint asset");
        AssetType at = AssetType(IBaseAsset(asset).assetType());
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

    function revoke(address asset, address holder, uint256 amountOrTokenId) public onlyRole(SIGNER_ROLE) notUpgraded nonReentrant {
        AssetType at = AssetType(IBaseAsset(asset).assetType());
        if(at == AssetType.ERC20) {
            IERC20Asset(asset).revoke(holder, amountOrTokenId);
        } else if(at == AssetType.ERC721) {
            IERC721Asset(asset).revoke(amountOrTokenId);
        } else {
            revert("Company: unsupported asset type");
        }
        emit AssetRevoked(asset, holder, amountOrTokenId);
    }

    function upgrade(bytes memory initData) public onlyRole(DEFAULT_ADMIN_ROLE) notUpgraded {
        upgraded = true;
        companyRegistry.upgradeCompany(initData);
    }

    function upgradeComplete(address nextVersion) public onlyRegistry nonReentrant {
        uint256 bal = address(this).balance;
        if(bal > 0) {
            payable(nextVersion).transfer(bal);
        }
        INextVersion(nextVersion).setStartingPSub(nextPsub);
        emit CompanyUpgraded(address(this), nextVersion);
    }

    function withdraw (uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amount <= address(this).balance, "Company: insufficient balance");
        payable(owner).transfer(amount);
    }

    function setHook(ICompanyHook _hook) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(_hook) != address(0), "Company: hook cannot be 0x0");
        hook = _hook;
    }
    
    function removeHook() public onlyRole(DEFAULT_ADMIN_ROLE) {
        hook = ICompanyHook(address(0));
    }

    function addExperienceCondition(address experience, address condition) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IExperience exp = IExperience(experience);
        exp.addPortalCondition(IPortalCondition(condition));
    }

    function removeExperienceCondition(address experience) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IExperience exp = IExperience(experience);
        exp.removePortalCondition();
    }

    function changeExperiencePortalFee(address experience, uint256 fee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        IExperience exp = IExperience(experience);
        exp.changePortalFee(fee);
    }
}
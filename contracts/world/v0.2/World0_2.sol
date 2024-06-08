// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorld0_2, CompanyRegistrationArgs} from './IWorld0_2.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {VectorAddress} from '../../VectorAddress.sol';
import {IAvatarRegistry, AvatarRegistrationRequest} from '../../avatar/IAvatarRegistry.sol';
import {WorldCreateRequest} from './IWorldFactory0_2.sol';
import {ICompanyRegistry, CompanyRegistrationRequest} from '../../company/ICompanyRegistry.sol';
import {IWorldRegistry0_2} from './IWorldRegistry0_2.sol';
import {LibStringCase} from '../../LibStringCase.sol';
import {IWorld} from '../v0.1/IWorld.sol';
import {IWorldHook} from './IWorldHook.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

struct WorldConstructorArgs {
    address worldFactory;
    address worldRegistry;
    address companyRegistry;
    address avatarRegistry;
}

contract World0_2 is IWorld0_2, ReentrancyGuard, AccessControl {
    using LibStringCase for string;

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    string public constant override version = "0.2";
    
    //Fields populated at master copy deploy time
    IWorldRegistry0_2 public immutable worldRegistry;
    address public immutable worldFactory;
    ICompanyRegistry public immutable companyRegistry;
    IAvatarRegistry public immutable avatarRegistry;

    modifier onlyFactory {
        require(worldFactory != address(0), "World0_2: worldFactory not set");
        require(msg.sender == worldFactory, "World0_2: caller is not factory");
        _;
    }

    modifier onlyRegistry {
        require(address(worldRegistry) != address(0), "World0_2: worldRegistry not set");
        require(msg.sender == address(worldRegistry), "World0_2: caller is not registry");
        _;
    }

    //fields populated by init function
    bool public upgraded;
    address owner;
    address oldVersion;
    IWorldHook public hook;
    VectorAddress baseVector;
    string public name;
    uint256 nextP;

    modifier notUpgraded {
        require(!upgraded, "World0_2: world already upgraded");
        _;
    }

    modifier onlySigner {
        require(hasRole(SIGNER_ROLE, msg.sender), "World0_2: caller is not signer");
        _;
    }

    constructor(WorldConstructorArgs memory args) {
        require(args.worldFactory != address(0), "World0_2: worldFactory cannot be zero address");
        require(args.worldRegistry != address(0), "World0_2: worldRegistry cannot be zero address");
        require(args.companyRegistry != address(0), "World0_2: companyRegistry cannot be zero address");
        require(args.avatarRegistry != address(0), "World0_2: avatarRegistry cannot be zero address");
        worldRegistry = IWorldRegistry0_2(args.worldRegistry);
        worldFactory = args.worldFactory;
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
    }

    receive() external payable {
        emit ReceivedFunds(msg.sender, msg.value);
    }

    function init(WorldCreateRequest memory request) external onlyFactory {
        require(request.owner != address(0), "World0_2: owner cannot be zero address");
        require(bytes(request.baseVector.x).length != 0, "World0_2: baseVector.x cannot be zero");
        require(bytes(request.baseVector.y).length != 0, "World0_2: baseVector.y cannot be zero");
        require(bytes(request.baseVector.z).length != 0, "World0_2: baseVector.z cannot be zero");
        require(request.baseVector.p == 0, "World0_2: baseVector.p must be zero");
        require(request.baseVector.p_sub == 0, "World0_2: baseVector.p_sub must be zero");
        require(bytes(request.name).length > 0, "World0_2: name cannot be empty");
        owner = request.owner;
        baseVector = request.baseVector;
        name = request.name;
        nextP = 0;
        oldVersion = request.oldWorld;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(SIGNER_ROLE, owner);
        if(request.oldWorld != address(0)) {
            address oldOwner = IWorld(request.oldWorld).getOwner();
            if(oldOwner != owner) {
                //only grant old owner signer role to mitigate security implications. 
                _grantRole(SIGNER_ROLE, oldOwner);
            }
        }
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getBaseVector() external view returns (VectorAddress memory) {
        return baseVector;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    function upgrade(bytes calldata initData) public onlyRole(SIGNER_ROLE) notUpgraded {
        upgraded = true;
        worldRegistry.worldUpgradeSelf(initData);
    }

    function upgradeComplete(address nextVersion) public onlyRegistry {
        upgraded = true;
        uint256 bal = address(this).balance;
        if(bal > 0) {
            payable(nextVersion).transfer(bal);
        }
        emit WorldUpgraded(address(this), nextVersion);
    }
    
    function addSigners(address[] memory sigs) external onlyRole(DEFAULT_ADMIN_ROLE) notUpgraded {
        for (uint256 i = 0; i < sigs.length; i++) {
            require(sigs[i] != address(0), "World0_2: signer cannot be zero address");
            require(_grantRole(SIGNER_ROLE, sigs[i]), "World0_2: signer role failed");
            emit SignerAdded(sigs[i]);
        }
    }

    function removeSigners(address[] memory sigs) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < sigs.length; i++) {
            require(sigs[i] != address(0), "World0_2: signer cannot be zero address");
            _revokeRole(SIGNER_ROLE, sigs[i]);
            emit SignerRemoved(sigs[i]);
        }
    }

    function isSigner(address signer) external view override returns (bool) {
        return hasRole(SIGNER_ROLE, signer);
    }

    function registerCompany(CompanyRegistrationArgs memory args) public  onlySigner nonReentrant returns (address company) {
        require(args.owner != address(0), "World0_2: company owner cannot be zero address");
        require(bytes(args.name).length > 0, "World0_2: company name cannot be empty");
        if(address(hook) != address(0)) {
            require(hook.beforeRegisterCompany(args), "World0_2: hook rejected company registration");
        }

        ++nextP;
        VectorAddress memory vector = VectorAddress({
            x: baseVector.x,
            y: baseVector.y,
            z: baseVector.z,
            t: baseVector.t,
            p: nextP,
            p_sub: 0
        });
        company = companyRegistry.registerCompany(CompanyRegistrationRequest({
            owner: args.owner,
            vector: vector,
            name: args.name,
            initData: args.initData
        }));
        emit CompanyRegistered(company, vector, args.name);
    }

    function registerAvatar(AvatarRegistrationRequest memory args) external onlySigner nonReentrant returns (address avatar) {
        require(args.avatarOwner != address(0), "World0_2: avatar owner cannot be zero address");
        require(bytes(args.username).length > 0, "World0_2: avatar username cannot be empty");
        if(address(hook) != address(0)) {
            require(hook.beforeRegisterAvatar(args), "World0_2: hook rejected avatar registration");
        }

        avatar = avatarRegistry.registerAvatar(AvatarRegistrationRequest({
            avatarOwner: args.avatarOwner,
            username: args.username,
            defaultExperience: args.defaultExperience,
            initData: args.initData,
            sendTokensToAvatarOwner: args.sendTokensToAvatarOwner
        }));
        emit AvatarRegistered(avatar, args.defaultExperience);
    }

    function setHook(IWorldHook _hook) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(address(_hook) != address(0), "World0_2: hook cannot be zero address");
        hook = _hook;
        emit WorldHookSet(address(_hook));
    }

    function removeHook() external onlyRole(DEFAULT_ADMIN_ROLE) {
        hook = IWorldHook(address(0));
        emit WorldHookRemoved();
    }

    function withdraw(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amount <= address(this).balance, "World0_2: amount exceeds balance");
        payable(owner).transfer(amount);
    }
    
}
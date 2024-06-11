// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorldRegistry0_2, WorldRegistrationRequest} from './IWorldRegistry0_2.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IWorldFactory0_2, WorldCreateRequest} from './IWorldFactory0_2.sol';
import {LibStringCase} from '../../LibStringCase.sol';
import {IRegistrarRegistry} from '../../IRegistrarRegistry.sol';
import {VectorAddress, LibVectorAddress} from '../../VectorAddress.sol';
import {IWorld} from '../v0.1/IWorld.sol';
import {IWorld0_2} from './IWorld0_2.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';

struct WorldRegistryContructorArgs {
    address vectorAuthority;
    address worldFactory;
    address registrarRegistry;
    address defaultAdmin;
    address oldWorldRegistry;
}

interface IWorldRegistry0_1 {
    function isWorld(address world) external view returns (bool);
    function isVectorAddressAuthority(address auth) external view returns(bool);
}

contract WorldRegistry0_2 is IWorldRegistry0_2, ReentrancyGuard, AccessControl {
    using LibStringCase for string;
    using LibVectorAddress for VectorAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VECTOR_AUTHORITY_ROLE = keccak256("VECTOR_AUTHORITY_ROLE");
    

    address public vectorAuthority;
    IWorldFactory0_2 public worldFactory;
    IWorldRegistry0_1 public previousRegistry;
    IRegistrarRegistry public registrarRegistry;
    mapping(string => address) _worldsByName;
    mapping(address => bool) _worlds;
    mapping(bytes32 => address) _worldsByVector;
    string public currentWorldVersion = "0.2";

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "WorldRegistry0_2: caller is not admin");
        _;
    }

    modifier onlyRegistrar(uint256 id) {
        require(registrarRegistry.isRegistrar(id, msg.sender), "WorldRegistry0_2: caller is not a valid registrar");
        _;
    }

    modifier onlyWorld {
        require(_worlds[msg.sender], "WorldRegistry0_2: caller is not a valid World");
        _;
    }

    constructor(WorldRegistryContructorArgs memory args) {
        require(args.vectorAuthority != address(0), "WorldRegistry0_2: vectorAuthority cannot be 0x0");
        require(args.worldFactory != address(0), "WorldRegistry0_2: worldFactory cannot be 0x0");
        require(args.defaultAdmin != address(0), "WorldRegistry0_2: defaultAdmin cannot be 0x0");
        require(args.registrarRegistry != address(0), "WorldRegistry0_2: registrarRegistry cannot be 0x0");

        vectorAuthority = args.vectorAuthority;
        worldFactory = IWorldFactory0_2(args.worldFactory);
        previousRegistry = IWorldRegistry0_1(args.oldWorldRegistry);
        registrarRegistry = IRegistrarRegistry(args.registrarRegistry);
        _grantRole(DEFAULT_ADMIN_ROLE, args.defaultAdmin);
        _grantRole(ADMIN_ROLE, args.defaultAdmin);
        _grantRole(VECTOR_AUTHORITY_ROLE, args.defaultAdmin);
    }

    receive() external payable {
       
    }

    function setCurrentWorldVersion(string memory version) external onlyAdmin {
        currentWorldVersion = version;
    }

    function getWorldByName(string memory name) external view returns (address) {
        return _worldsByName[name.lower()];
    }

    function isWorld(address world) external view returns (bool) {
        return _worlds[world];
    }

    function isVectorAddressAuthority(address auth) external view returns(bool) {
        return hasRole(VECTOR_AUTHORITY_ROLE, auth);
    }

    function setWorldFactory(address factory) external onlyAdmin {
        require(factory != address(0), "WorldRegistry0_2: factory cannot be 0x0");
        worldFactory = IWorldFactory0_2(factory);
    }

    function addVectorAddressAuthority(address auth) external onlyAdmin {
        require(auth != address(0), "WorldRegistry0_2: auth cannot be 0x0");
        _grantRole(VECTOR_AUTHORITY_ROLE, auth);
    }

    function removeVectorAddressAuthority(address auth) external onlyAdmin {
        require(auth != address(0), "WorldRegistry0_2: auth cannot be 0x0");
        _revokeRole(VECTOR_AUTHORITY_ROLE, auth);
    }

    function register(WorldRegistrationRequest memory request) external payable onlyRegistrar(request.registrarId) nonReentrant  {
        string memory name = request.name.lower();
        require(_worldsByName[name] == address(0), "WorldRegistry0_2: name already in use");
        if(address(previousRegistry) != address(0) &&
           request.oldWorld != address(0)) {
            require(previousRegistry.isWorld(request.oldWorld), "WorldRegistry0_2: oldWorld is not a valid world from previous registry");
        }
        address signer = request.baseVector.getSigner(request.vectorAuthoritySignature);
        require(hasRole(VECTOR_AUTHORITY_ROLE, signer), "WorldRegistry0_2: vector signer is not a valid vector address authority");

        require(bytes(request.baseVector.x).length != 0, "WorldRegistry0_2: baseVector.x cannot be zero");
        require(bytes(request.baseVector.y).length != 0, "WorldRegistry0_2: baseVector.y cannot be zero");
        require(bytes(request.baseVector.z).length != 0, "WorldRegistry0_2: baseVector.z cannot be zero");
        VectorAddress memory va = VectorAddress({
            x: request.baseVector.x,
            y: request.baseVector.y,
            z: request.baseVector.z,
            t: request.baseVector.t,
            p: 0,
            p_sub: 0
        });
        bytes32 vHash = keccak256(bytes(va.asLookupKey()));
        require(_worldsByVector[vHash] == address(0), "WorldRegistry0_2: vector already in use");
        address world = worldFactory.createWorld(WorldCreateRequest({
            owner: request.owner,
            oldWorld: request.oldWorld,
            baseVector: va,
            name: name,
            initData: request.initData
        }));
        require(world != address(0), "WorldRegistry0_2: world creation failed");
        _worldsByName[name] = world;
        _worlds[world] = true;
        _worldsByVector[vHash] = world;
        if(msg.value > 0) {
            if(request.sendTokensToWorldOwner) {
                payable(request.owner).transfer(msg.value);
            } else {
                payable(address(world)).transfer(msg.value);
            }
        }
        emit WorldRegistered(world, request.owner, va);
    }

    function registrarUpgradeWorld(uint256 registrarId, address oldWorld, bytes calldata initData) external onlyRegistrar(registrarId) nonReentrant {
        
        require(previousRegistry.isWorld(oldWorld), "WorldRegistry0_2: oldWorld is not a valid world upgradeable by registrar");
        IWorld old = IWorld(oldWorld);

        WorldCreateRequest memory req = WorldCreateRequest({
            owner: old.getOwner(),
            oldWorld: oldWorld,
            baseVector: old.getBaseVector(),
            name: old.getName().lower(),
            initData: initData
        });
        address world = worldFactory.createWorld(req);
        require(world != address(0), "WorldRegistry0_2: world creation failed");
        _worldsByName[old.getName().lower()] = world;
        _worlds[world] = true;
        _worldsByVector[keccak256(bytes(old.getBaseVector().asLookupKey()))] = world;
        old.upgrade(world);
    }

    function worldUpgradeSelf(bytes calldata initData) public onlyWorld nonReentrant {
        worldFactory.upgradeWorld(msg.sender, initData);
    }

}
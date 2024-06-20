// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IWorldRegistry, WorldRegistrationRequest} from './IWorldRegistry.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IWorldFactory} from './IWorldFactory.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IRegistrarRegistry} from '../registrar/IRegistrarRegistry.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {IWorld} from './IWorld.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IRegistrar} from '../registrar/IRegistrar.sol';

struct WorldRegistryContructorArgs {
    address vectorAuthority;
    address worldFactory;
    address registrarRegistry;
    address defaultAdmin;
    address[] otherAdmins;
}

contract WorldRegistry is IWorldRegistry, ReentrancyGuard, AccessControl {
    using LibStringCase for string;
    using LibVectorAddress for VectorAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VECTOR_AUTHORITY_ROLE = keccak256("VECTOR_AUTHORITY_ROLE");

    address public vectorAuthority;
    IRegistrarRegistry public registrarRegistry;
    IWorldFactory public worldFactory;
    address _owner;
    mapping(string => address) _worldsByName;
    mapping(address => bool) _worlds;
    mapping(bytes32 => address) _worldsByVector;

    modifier onlyRegistrar() {
        require(registrarRegistry.isRegistrar(msg.sender), "WorldRegistry0_2: caller is not a valid registrar");
        _;
    }

    modifier onlyWorld {
        require(_worlds[msg.sender], "WorldRegistry0_2: caller is not a valid World");
        _;
    }

    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "WorldRegistry0_2: caller is not an admin");
        _;
    }

    constructor(WorldRegistryContructorArgs memory args) {
        require(args.vectorAuthority != address(0), "WorldRegistry0_2: vectorAuthority cannot be 0x0");
        require(args.worldFactory != address(0), "WorldRegistry0_2: worldFactory cannot be 0x0");
        require(args.defaultAdmin != address(0), "WorldRegistry0_2: defaultAdmin cannot be 0x0");
        require(args.registrarRegistry != address(0), "WorldRegistry0_2: registrarRegistry cannot be 0x0");

        vectorAuthority = args.vectorAuthority;
        worldFactory = IWorldFactory(args.worldFactory);
        registrarRegistry = IRegistrarRegistry(args.registrarRegistry);
        _grantRole(DEFAULT_ADMIN_ROLE, args.defaultAdmin);
        _grantRole(ADMIN_ROLE, args.defaultAdmin);
        _grantRole(VECTOR_AUTHORITY_ROLE, args.vectorAuthority);
        _owner = args.defaultAdmin;
        for(uint256 i = 0; i < args.otherAdmins.length; i++) {
            require(args.otherAdmins[i] != address(0), "WorldRegistry0_2: otherAdmins cannot contain 0x0");
            _grantRole(ADMIN_ROLE, args.otherAdmins[i]);
        }
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function getWorldByName(string memory name) external view returns (address) {
        return _worldsByName[name.lower()];
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function isWorld(address world) external view returns (bool) {
        return _worlds[world];
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function isVectorAddressAuthority(address auth) external view returns(bool) {
        return hasRole(VECTOR_AUTHORITY_ROLE, auth);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function setWorldFactory(address factory) external onlyAdmin {
        require(factory != address(0), "WorldRegistry0_2: factory cannot be 0x0");
        worldFactory = IWorldFactory(factory);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function addVectorAddressAuthority(address auth) external onlyAdmin {
        require(auth != address(0), "WorldRegistry0_2: auth cannot be 0x0");
        _grantRole(VECTOR_AUTHORITY_ROLE, auth);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function removeVectorAddressAuthority(address auth) external onlyAdmin {
        require(auth != address(0), "WorldRegistry0_2: auth cannot be 0x0");
        _revokeRole(VECTOR_AUTHORITY_ROLE, auth);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function register(WorldRegistrationRequest memory request) external payable onlyRegistrar nonReentrant returns (address)  {
        string memory name = request.name.lower();
        require(_worldsByName[name] == address(0), "WorldRegistry0_2: name already in use");
        address signer = request.baseVector.getSigner(msg.sender, request.vectorAuthoritySignature);
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
        address world = worldFactory.createWorld(WorldRegistrationRequest({
            vectorAuthoritySignature: request.vectorAuthoritySignature,
            registrar: msg.sender,
            owner: request.owner,
            baseVector: va,
            name: name,
            initData: request.initData,
            companyTerms: request.companyTerms,
            avatarTerms: request.avatarTerms
        }));
        require(world != address(0), "WorldRegistry0_2: world creation failed");
        _worldsByName[name] = world;
        _worlds[world] = true;
        _worldsByVector[vHash] = world;
        
        emit WorldRegistered(world, request.owner, va);
        return world;
    }

    /**
     * @inheritdoc IWorldRegistry
     */
     function deactivateWorld(address world) public onlyRegistrar {
        require(_worlds[world], "WorldRegistry0_2: world is not a valid world");
        IWorld w = IWorld(world);
        require(w.isActive(), "WorldRegistry0_2: world is not active");
        require(w.registrar() == msg.sender, "WorldRegistry0_2: world is not registered by the registrar");
        w.deactivate();
        _worlds[world] = false;
        emit RegistryDeactivatedWorld(world, msg.sender);
     }

     /**
        * @inheritdoc IWorldRegistry
      */
    function reactivateWorld(address world) public onlyRegistrar {
        IWorld w = IWorld(world);
        require(w.registrar() == msg.sender, "WorldRegistry0_2: world is not registered by the registrar");
        require(!w.isActive(), "WorldRegistry0_2: world is already active");
        string memory nm = w.getName().lower();
        require(_worldsByName[nm] == world, "WorldRegistry0_2: world name does not match registered name");

        w.reactivate();
        _worlds[world] = true;
        emit RegistryReactivatedWorld(world, msg.sender);
    }

    function removeWorld(address world) public onlyRegistrar {
        require(_worlds[world], "WorldRegistry0_2: world is not a valid world");
        IWorld w = IWorld(world);
        require(w.registrar() == msg.sender, "WorldRegistry0_2: world is not registered by the registrar");
        require(!w.isActive(), "WorldRegistry0_2: world is active");
        string memory nm = w.getName().lower();
        require(_worldsByName[nm] == world, "WorldRegistry0_2: world name does not match registered name");
        w.deactivate();
        delete _worlds[world];
        delete _worldsByName[nm];
        emit RegistryRemovedWorld(world, msg.sender);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function upgradeWorld(bytes calldata initData) public onlyWorld nonReentrant {
        worldFactory.upgradeWorld(msg.sender, initData);
    }

    /**
     * @inheritdoc IWorldRegistry
     */
    function currentWorldVersion() external view override returns (uint256) {
        return worldFactory.supportsVersion();
    }

}
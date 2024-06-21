// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRegistration} from '../BaseRegistration.sol';
import "./IRegistrarRegistry.sol";
import {IRegistrarFactory} from './IRegistrarFactory.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IRegistrar} from './IRegistrar.sol';
import {AccessControl} from '@openzeppelin/contracts/access/AccessControl.sol';
import {IWorld} from '../world/IWorld.sol';
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * @title RegistrarRegistry
 * @dev The registrar registry holds registrar IDs and their list of authorized signers. Registrars
 * are the only entity allowed to regsiter worlds in the world registry. They must go through XRDNA
 * to be approved as a registrar.
 */
contract RegistrarRegistry is IRegistrarRegistry, BaseRegistration, AccessControl, ReentrancyGuard {
    using LibStringCase for string;
    using MessageHashUtils for bytes;

    bytes32 public constant REGISTER_ROLE = keccak256("REGISTER_ROLE");
    bytes32 public constant TERMS_REGISTRAR = keccak256("TERMS_REGISTRAR");
    
    IRegistrarFactory public factory;
    address _owner;
    mapping(address => bool) public registrars;
    mapping(string => address) private registrarsByName;
    

    modifier onlyRegistrar {
        require(registrars[msg.sender], "RegistrarRegistry: registrar id does not exist");
        _;
    }

    modifier onlyRegisterer {
        require(hasRole(REGISTER_ROLE, msg.sender), "RegistrarRegistry: caller is not a registerer");
        _;
    }
    
    constructor(address mainAdmin, address[] memory registerers, IRegistrarFactory _factory)  {
        require(mainAdmin != address(0), "RegistrarRegistry: mainAdmin cannot be zero address");
        require(address(_factory) != address(0), "RegistrarRegistry: factory cannot be zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, mainAdmin);
        _grantRole(ADMIN_ROLE, mainAdmin);
        _grantRole(REGISTER_ROLE, mainAdmin);
        _owner = mainAdmin;
        factory = _factory;
        for (uint256 i = 0; i < registerers.length; i++) {
            require(registerers[i] != address(0), "RegistrarRegistry: registerer cannot be address");
            _grantRole(REGISTER_ROLE, registerers[i]);
        }
    }

    function isAdmin(address a) internal view override returns (bool) {
        return hasRole(ADMIN_ROLE, a);
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    /**
     * @inheritdoc IRegistrarRegistry
     */
    function isRegistrar(address reg) public view returns (bool) {
        return registrars[reg];
    }

    /**
        * @inheritdoc IRegistrarRegistry
     */
    function getRegistrarByName(string memory name) public view returns (address) {
        return registrarsByName[name.lower()];
    }

    /**
     * @inheritdoc IRegistrarRegistry
     */
    function register(CreateRegistrarArgs calldata args) public payable onlyRegisterer nonReentrant {
        require(args.owner != address(0), "RegistrarRegistry: owner cannot be zero address");
        string memory nm = args.name.lower();
        require(registrarsByName[nm] == address(0), "RegistrarRegistry: registrar name already exists");

        address registrar = factory.createRegistrar(args);
        require(registrar != address(0), "RegistrarRegistry: registrar cannot be zero address");
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(registrar).transfer(msg.value);
            }
        }
        createRegistration(TERMS_REGISTRAR, registrar);
        registrars[registrar] = true;
        registrarsByName[nm] = registrar;
        emit RegistryAddedRegistrar(registrar, args.owner, msg.value);
    }

     /**
     * @dev Deactivates a registrar. This can only be called by admin.
     */
    function deactivateRegistrar(address registrar) external onlyRegisterer {
        require(isRegistrar(registrar), "RegistrarRegistry: registrar does not exist");
        IRegistrar(registrar).deactivate();
        emit RegistryDeactivatedRegistrar(registrar);
    }

    /**
     * @dev Reactivates a registrar. This can only be called by admin.
     */
    function reactivateRegistrar(address registrar) external onlyRegisterer {
        require(isRegistrar(registrar), "RegistrarRegistry: registrar does not exist");
        IRegistrar(registrar).reactivate();
        emit RegistryReactivatedRegistrar(registrar);
    }

    /**
     * @inheritdoc IRegistrarRegistry
     */
    function removeRegistrar(address registrar) public onlyRegisterer {
        string memory nm = IRegistrar(registrar).name().lower();
        delete registrars[registrar];
        delete registrarsByName[nm];
        emit RegistryRemovedRegistrar(registrar);
    }

    /**
     * @dev Pays for the renewal of the given address. Anyone can call this function.
     */
    function renewRegistrarRegistration(address addr) public payable {
        renewFor(TERMS_REGISTRAR, addr);
    }

    /**
     * @inheritdoc IRegistrarRegistry
     */
     function currentRegistrarVersion() external view override returns (uint256) {
        return factory.supportsVersion();
     }

    function migrateRegistrar(WorldMigrationArgs calldata args) public override onlyRegistrar {
        _verifyMigrationSigs(args);
        IWorld(args.world).registrarChanged(msg.sender);
    }

    function upgradeRegistrar(bytes calldata initData) public override onlyRegistrar {
        address next = factory.upgradeRegistrar(msg.sender, initData);
        emit RegistryUpgradedRegistrar(msg.sender, next);
    }

     function _verifyMigrationSigs(WorldMigrationArgs calldata args) internal view {
        require(args.expiration > block.timestamp, "Registrar: migration signature expired");
        IWorld world = IWorld(args.world);
        IRegistrar oldRegistrar = IRegistrar(world.registrar());
        bytes32 hash = keccak256(abi.encode(args.world, address(this), args.expiration));
        bytes memory b = new bytes(32);
        assembly {
            mstore(add(b, 32), hash) // set the bytes data
        }
        //make sure signer is a signer for the destination experience's company
        bytes32 sigHash = b.toEthSignedMessageHash();
        
        if(args.currentRegistrarSignature.length == 0) {
            require(!oldRegistrar.isActive(), "Registrar: current registrar is active but no signature provided");
        } else {
            address r = ECDSA.recover(sigHash, args.currentRegistrarSignature);
            require(r == address(oldRegistrar), "Registrar: current registrar signature invalid");
        }
        address w = ECDSA.recover(sigHash, args.worldSignature);
        require(w == args.world, "Registrar: world signature invalid");
    }
}
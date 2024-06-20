// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseAccess} from '../BaseAccess.sol';
import {IRegistrar} from './IRegistrar.sol';
import {BaseProxyStorage, LibBaseProxy, LibProxyAccess} from '../libraries/LibBaseProxy.sol';
import {BaseHookSupport} from '../BaseHookSupport.sol';
import {RegistrarV1Storage, LibRegistrarV1Storage} from '../libraries/LibRegistrarV1Storage.sol';
import {RegistrationTerms, RegistrationRenewalStorage, LibRegistration} from '../libraries/LibRegistration.sol';
import {WorldRegistrationArgs} from './IRegistrar.sol';
import {WorldRegistrationRequest, IWorldRegistry} from '../world/IWorldRegistry.sol';
import {BaseRegistration} from '../BaseRegistration.sol';
import {IWorld} from '../world/IWorld.sol';
import {WorldMigrationArgs, IRegistrarRegistry} from './IRegistrarRegistry.sol';
import {IRegistrarHook} from './IRegistrarHook.sol';
import {HookStorage, LibHooks} from '../libraries/LibHooks.sol';
import {LibRegistration} from '../libraries/LibRegistration.sol';
import {CreateRegistrarArgs} from './IRegistrarRegistry.sol';

struct RegistrarConstructorArgs {
    address registrarFactory;
    address registrarRegistry;
    address worldRegistry;
}

contract Registrar is IRegistrar, BaseAccess, BaseHookSupport, BaseRegistration {
    using LibBaseProxy for BaseProxyStorage;
    using LibRegistration for RegistrationRenewalStorage;
    using LibHooks for HookStorage;

    uint256 constant public version = 1;

    address public immutable registrarFactory;
    IRegistrarRegistry public immutable registrarRegistry;
    IWorldRegistry public immutable worldRegistry;
    bytes32 public constant WORLD_TERMS = keccak256("WORLD_TERMS");

    modifier onlyFactory {
        require(registrarFactory != address(0), "Registrar: factory not set");
        require(msg.sender == registrarFactory, "Registrar: caller is not the factory");
        _;
    }

    modifier onlyRegistry {
        require(address(registrarRegistry) != address(0), "Registrar: registry not set");
        require(msg.sender == address(registrarRegistry), "CompRegistrarany: caller is not the registry");
        _;
    }

    modifier onlyActive {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        require(s.active, "Registrar: is not active");
        _;
    }


    constructor(RegistrarConstructorArgs memory args) {
        require(args.registrarFactory != address(0), "Registrar: factory is the zero address");
        require(args.registrarRegistry != address(0), "Registrar: registry is the zero address");
        require(args.worldRegistry != address(0), "Registrar: world registry is the zero address");
        registrarFactory = args.registrarFactory;
        registrarRegistry = IRegistrarRegistry(args.registrarRegistry);
        worldRegistry = IWorldRegistry(args.worldRegistry);
    }

    function init(CreateRegistrarArgs calldata args) external override onlyFactory {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        require(args.owner != address(0), "Registrar: owner is the zero address");
        require(bytes(args.name).length > 0, "Registrar: name is empty");

        require(s.owner == address(0), "Registrar: already initialized");

        s.name = args.name;
        s.active = true;
        s.owner = args.owner;
        address[] memory signers = new address[](1);
        signers[0] = args.owner;
        _addSigners(signers);
        LibRegistration.load().setTerms(WORLD_TERMS, args.worldRegistrationTerms);
    }


    function isAdmin(address account) internal view override (BaseHookSupport,BaseRegistration)  returns (bool) {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        return account == s.owner;
    }

    function owner() public view override returns (address) {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        return s.owner;
    }

    /**
     * @dev Returns the name of the registrar
     */
    function name() external view returns (string memory) {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        return s.name;
    }

    /**
     * @inheritdoc IRegistrar
     */
    function isActive() external view returns (bool) {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        return s.active;
    }

    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(WorldRegistrationArgs memory args) external payable onlySigner returns (address world) {
        IRegistrarHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRegisterWorld(args), "Registrar: hook rejected world registration");
        }
        WorldRegistrationRequest memory request = WorldRegistrationRequest({
            registrar: address(this),
            name: args.name,
            baseVector: args.baseVector,
            owner: args.owner,
            initData: args.initData,
            vectorAuthoritySignature: args.vectorAuthoritySignature,
            companyTerms: args.companyTerms,
            avatarTerms: args.avatarTerms
        });
        world = worldRegistry.register(request);
        require(world != address(0), "Registrar: world not registered");

        if(msg.value > 0) {
            if(args.sendTokensToWorldOwner) {
                payable(request.owner).transfer(msg.value);
            } else {
                payable(world).transfer(msg.value);
            }
        }
        createRegistration(WORLD_TERMS, world);
        emit WorldRegistered(world, args.owner, args.baseVector);
    }

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world) external onlySigner {
        IRegistrarHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeDeactivateWorld(world), "Registrar: hook rejected world deactivation");
        }
        worldRegistry.deactivateWorld(world);
    }

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external onlySigner {
        IRegistrarHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeReactivateWorld(world), "Registrar: hook rejected world reactivation");
        }
        worldRegistry.reactivateWorld(world);
    }

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world) external onlySigner {
        IRegistrarHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRemoveWorld(world), "Registrar: hook rejected world removal");
        }
        worldRegistry.removeWorld(world);
    }

    /**
     * @dev Migrate a world to a new registrar
     */
    function migrateWorld(WorldMigrationArgs calldata args) external onlySigner {
        IRegistrarHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeMigrateWorld(args), "Registrar: hook rejected world migration");
        }
        registrarRegistry.migrateRegistrar(args);
        //set new terms for the incoming world
        createRegistration(WORLD_TERMS, args.world);
    }

    /**
     * @dev Renews the registration of a world. Can be called by anyone willing to 
     * pay the renewal fee
     */
    function renewWorldRegistration(address world) external payable {
        IRegistrarHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeRenewWorldRegistration(world), "Registrar: hook rejected world renewal");
        }
        renewFor(WORLD_TERMS, world);
    }

    /**
     * @dev Deactivate the registrar. This will prevent any new registrations from being made
     * and will deactivate all existing worlds. Can only be called by the RegistrarRegistry
     */
    function deactivate() external override onlyRegistry {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        s.active = false;
        if(address(this).balance > 0) {
            payable(s.owner).transfer(address(this).balance);
        }

        emit RegistrarDeactivated();
    }

    /**
     * @dev Reactivate the registrar. Can only be called by the RegistrarRegistry
     */
    function reactivate() external override onlyRegistry {
        RegistrarV1Storage storage s = LibRegistrarV1Storage.load();
        s.active = true;
        emit RegistrarReactivated();
    }

    /**
        * @dev Upgrades the registrar to a new version. Must be called by admin
     */
    function upgrade(bytes calldata initData) external {
        IRegistrarHook hook = _getHook();
        if(address(hook) != address(0)) {
            require(hook.beforeUpgrade(initData), "Registrar: hook rejected upgrade");
        }
        registrarRegistry.upgradeRegistrar(initData);
    }

    /**
     * @dev Complete upgrade and set implementation to the next version. This is called
     * by the factory after new proxy is deployed
     */
    function upgradeComplete(address nextVersion) external override onlyFactory {
        LibBaseProxy.load().implementation = nextVersion;
        emit RegistrarUpgraded(nextVersion);
    }
    
    function _getHook() internal view returns (IRegistrarHook) {
        return IRegistrarHook(LibHooks.load().getHook());
    }
}
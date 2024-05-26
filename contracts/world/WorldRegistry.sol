// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {IRegistrarRegistry} from '../IRegistrarRegistry.sol';
import {VectorAddress, LibVectorAddress} from '../VectorAddress.sol';
import {LibStringCase} from '../LibStringCase.sol';
import {IBasicWorld} from './IWorld.sol';
import {IWorldFactory} from './IWorldFactory.sol';

interface IWorldRegistry {
    function isWorld(address world) external view returns (bool);
    function register(uint256 registrarId, address _owner, bytes calldata initData, bool tokensToOwner) external payable;
    function upgradeWorld(uint256 registrarId, address oldWorld, bytes calldata initData) external;
}

contract WorldRegistry is IWorldRegistry, AccessControl {
    
    using LibVectorAddress for VectorAddress;
    using LibStringCase for string;

    IRegistrarRegistry public registrarRegistry;
    IWorldFactory public worldFactory;
    mapping(address => address) public worldsByContractAddress;
    mapping(string => address) public worldsVectorAddress;
    mapping(string => address) public worldsByName;

    modifier onlyRegistrar(uint256 registrarId) {

        require(registrarRegistry.isRegistrar(registrarId, msg.sender), "WorldRegistry: caller is not a valid registrar");
        _;
    }

    modifier onlyWorld(address world) {
        require(isWorld(world), "WorldRegistry: caller is not a valid World");
        _;
    }

    event WorldRegistered(address indexed world, address indexed owner, VectorAddress vectorAddress);

    constructor(IRegistrarRegistry regRegistry, IWorldFactory factory, address defaultAdmin) {
        registrarRegistry = regRegistry;
        worldFactory = factory;
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function isWorld(address world) public view returns (bool) {
        return worldsByContractAddress[world] != address(0x0);
    }

    function register(uint256 registrarId, address _owner, bytes calldata initData, bool tokensToOwner) public payable onlyRegistrar(registrarId) {
        
        address w = worldFactory.createWorld(_owner, initData);
        require(w != address(0x0), "WorldRegistry: world creation failed");
        string memory nm = IBasicWorld(w).getName().lower();
        require(address(worldsByName[nm]) == address(0x0), "WorldRegistry: name already in use");
        
        worldsByContractAddress[w] = w;

        worldsVectorAddress[IBasicWorld(w).getBaseVector().asLookupKey()] = w;
        worldsByName[nm] = w;
        if(msg.value > 0) {
            if(tokensToOwner) {
                payable(_owner).transfer(msg.value);
            } else {
                //could fail if world impl doesn't accept transfers
                payable(w).transfer(msg.value);
            }
        }
        emit WorldRegistered(address(w), _owner, IBasicWorld(w).getBaseVector());
    }

    function upgradeWorld(uint256 registrarId, address oldWorld, bytes calldata initData) public onlyRegistrar(registrarId) {
        
        require(isWorld(oldWorld), "WorldRegistry: world not found");
        address _owner = IBasicWorld(oldWorld).getOwner();
        address newWorld = worldFactory.createWorld(_owner, initData);
        require(newWorld != address(0x0), "WorldRegistry: world creation failed");

        delete worldsByContractAddress[oldWorld];
        worldsByContractAddress[newWorld] = newWorld;

        delete worldsVectorAddress[IBasicWorld(oldWorld).getBaseVector().asLookupKey()];
        worldsVectorAddress[IBasicWorld(newWorld).getBaseVector().asLookupKey()] = newWorld;
        
        delete worldsByName[IBasicWorld(oldWorld).getName().lower()];

        string memory nm = IBasicWorld(newWorld).getName().lower();
        require(worldsByName[nm] == address(0x0), "WorldRegistry: name already in use");
        worldsByName[nm] = newWorld;

        IBasicWorld(oldWorld).upgrade(newWorld);
        
    }

}
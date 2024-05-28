// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import { VectorAddress, LibVectorAddress } from "../VectorAddress.sol";
import { IWorld } from "./IWorld.sol";
import {IWorldRegistry} from "./WorldRegistry.sol";
import {IWorldFactory} from "./IWorldFactory.sol";
//import "hardhat/console.sol";

struct WorldInfo {
        string name;
        VectorAddress baseVector;
}

contract World is IWorld, AccessControl {

    string public constant version = "1.0.0";

    using LibVectorAddress for VectorAddress;

    IWorldFactory public immutable worldFactory;
    IWorldRegistry public immutable worldRegistry;
    
    bool public initialized;
    address public owner;
    
    VectorAddress public baseVector;
    string public name;
    

    event ReceivedFunds(address indexed sender, uint256 value);
    event SignerAdded(address indexed signer);
    event SignerRemoved(address indexed signer);

    modifier onlyWorldFactory() {
       // console.log("WorldFactory sender", msg.sender, address(worldFactory));
        require(msg.sender == address(worldFactory), "World: caller is not the world factory");
        _;
    }

    modifier onlyWorldRegistry() {
        require(msg.sender == address(worldRegistry), "World: caller is not the world registry");
        _;
    }

    /**
     * @dev This is called once when deployed. It serves as the master copy of 
     * of all world instances. A delegated clone is generated or each world and 
     * each instance's 'init' method is called with world details.
     */
    constructor(address factory, address registry) {
        require(factory != address(0), "World: factory cannot be zero address");
        require(registry != address(0), "World: registry cannot be zero address");
        worldFactory = IWorldFactory(factory);
        worldRegistry = IWorldRegistry(registry);
        
    }

    function encodeInfo(WorldInfo memory info) public pure returns (bytes memory) {
        return abi.encode(info);
    }

    function init(address _owner, bytes calldata initData) public onlyWorldFactory() {
        
        require(!initialized, "World: already initialized");
        //console.log("Decoding init data");
        (WorldInfo memory info) = abi.decode(initData, (WorldInfo));
        //console.log("Decoded init data", info.name, info.baseVector.asLookupKey());
        baseVector = info.baseVector;
        name = info.name;
        owner = _owner;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        initialized = true;
    }

    receive() external payable {
        emit ReceivedFunds(msg.sender, msg.value);
    }

    function getOwner() public view override returns (address) {
        return owner;
    }

    function getBaseVector() public view override returns (VectorAddress memory) {
        return baseVector;
    }

    function getName() public view override returns (string memory) {
        return name;
    }

    function addSigners(address[] memory sigs) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < sigs.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, sigs[i]);
            emit SignerAdded(sigs[i]);
        }
    }

    function removeSigners(address[] memory sigs) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < sigs.length; i++) {
            _revokeRole(DEFAULT_ADMIN_ROLE, sigs[i]);
            emit SignerRemoved(sigs[i]);
        }
    }

    function isSigner(address signer) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, signer);
    }

    function upgrade(address newWorld) public onlyWorldRegistry() {
        require(newWorld != address(0), "World: new world cannot be zero address");
        if(address(this).balance > 0) {
            payable(newWorld).transfer(address(this).balance);
        }
    }

    function withdraw(uint256 amt) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amt <= address(this).balance, "World: insufficient balance");
        payable(owner).transfer(amt);
    }
}

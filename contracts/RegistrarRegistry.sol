// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IRegistrarRegistry.sol";
//import "hardhat/console.sol";



contract RegistrarRegistry is IRegistrarRegistry, AccessControl {

    struct Registrar {
        uint256 id;
        mapping(address=>bool) signers;
    }

    event RegistrarAdded(uint256 id, address payable signer, uint256 tokens);
    event SignersAdded(uint256 id, address[] signers);
    event SignersRemoved(uint256 id, address[] signers);

    uint256 public registrarCount;
    mapping(uint256 => Registrar) public registrars;
    

    modifier onlyRegistrar(uint256 registrarId) {
        /*console.log("----------- Begin onlyRegistrar -----------");
        console.log("msg.sender", msg.sender);
        console.log("registrars[registrarId].signers[msg.sender]", registrars[registrarId].signers[msg.sender]);
        console.log("check ID", registrarId);
        console.log("----------- End onlyRegistrar -----------");
        */
        require(registrars[registrarId].signers[msg.sender], "RegistrarRegistry: caller is not the registrar");
        _;
    }

    constructor(address defaultAdmin, address[] memory registerers) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        for (uint256 i = 0; i < registerers.length; i++) {
            _grantRole(DEFAULT_ADMIN_ROLE, registerers[i]);
        }
    }

    function isRegistrar(uint256 id, address account) public view returns (bool) {
        return registrars[id].signers[account];
    }

    function register(address payable signer) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        //console.log("----------- Register Begin -----------");
        ++registrarCount;
        Registrar storage registrar = registrars[registrarCount];
        //console.log("registrar.id", registrarCount);
        registrar.id = registrarCount;
        registrar.signers[signer] = true;
        if(msg.value > 0) {
            signer.transfer(msg.value);
        }
        emit RegistrarAdded(registrarCount, signer, msg.value);
        //console.log("----------- Register End -----------");
    }

    function addSigners(uint256 registrarId, address[] memory signers) public onlyRegistrar(registrarId) {
        Registrar storage registrar = registrars[registrarId];
        for (uint256 i = 0; i < signers.length; i++) {
            //console.log("adding signer", signers[i]);
            registrar.signers[signers[i]] = true;
        }
        emit SignersAdded(registrarId, signers);
    }

    function removeSigners(uint256 registrarId, address[] memory signers) public onlyRegistrar(registrarId) {
        Registrar storage registrar = registrars[registrarId];
        for (uint256 i = 0; i < signers.length; i++) {
            delete registrar.signers[signers[i]];
        }
        emit SignersRemoved(registrarId, signers);
    }

}
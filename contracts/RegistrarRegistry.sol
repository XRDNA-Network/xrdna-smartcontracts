// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IRegistrarRegistry.sol";
//import "hardhat/console.sol";



contract RegistrarRegistry is IRegistrarRegistry, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REGISTER_ROLE = keccak256("REGISTER_ROLE");

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
        require(registrars[registrarId].signers[msg.sender], "RegistrarRegistry: caller is not a registrar");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "RegistrarRegistry: caller is not an admin");
        _;
    }

    modifier onlyRegisterer {
        require(hasRole(REGISTER_ROLE, msg.sender), "RegistrarRegistry: caller is not a registerer");
        _;
    }

    constructor(address mainAdmin, address[] memory registerers) {
        require(mainAdmin != address(0), "RegistrarRegistry: mainAdmin cannot be zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, mainAdmin);
        _grantRole(ADMIN_ROLE, mainAdmin);
        for (uint256 i = 0; i < registerers.length; i++) {
            require(registerers[i] != address(0), "RegistrarRegistry: registerer cannot be address");
            _grantRole(REGISTER_ROLE, registerers[i]);
        }
    }

    function isRegistrar(uint256 id, address account) public view returns (bool) {
        return registrars[id].signers[account];
    }

    function register(address payable signer) public payable onlyRegisterer() {
        require(signer != address(0), "RegistrarRegistry: signer cannot be zero address");
        ++registrarCount;
        Registrar storage registrar = registrars[registrarCount];
        registrar.id = registrarCount;
        registrar.signers[signer] = true;
        if(msg.value > 0) {
            signer.transfer(msg.value);
        }
        emit RegistrarAdded(registrarCount, signer, msg.value);
    }

    function removeRegistrar(uint256 registrarId) public onlyAdmin {
        delete registrars[registrarId];
    }

    function addSigners(uint256 registrarId, address[] memory signers) public onlyRegistrar(registrarId) {
        Registrar storage registrar = registrars[registrarId];
    
        for (uint256 i = 0; i < signers.length; i++) {
            require(signers[i] != address(0), "RegistrarRegistry: signer cannot be zero address");
            registrar.signers[signers[i]] = true;
        }
        emit SignersAdded(registrarId, signers);
    }

    function removeSigners(uint256 registrarId, address[] memory signers) public onlyRegistrar(registrarId) {
        Registrar storage registrar = registrars[registrarId];
        for (uint256 i = 0; i < signers.length; i++) {
            require(signers[i] != address(0), "RegistrarRegistry: signer cannot be zero address");
            delete registrar.signers[signers[i]];
        }
        emit SignersRemoved(registrarId, signers);
    }

}
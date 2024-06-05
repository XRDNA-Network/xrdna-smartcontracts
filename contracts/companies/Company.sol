// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import { ICompany } from "./ICompany.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct CompanyInfo {
    string name;
}

contract Company is ICompany, AccessControl {
    string public name;
    ICompanyFactory public immutable companyFactory;
    ICompanyRegistry public immutable companyRegistry;

    modifier onlyCompanyFactory() {
        require(msg.sender == address(companyFactory), "Company: caller is not the company factory");
        _;
    }

    modifier onlyCompanyRegistry() {
        require(msg.sender == address(companyRegistry), "Company: caller is not the company registry");
        _;
    }

    event ReceivedFunds(address indexed sender, uint256 value);
    event SignerAdded(address indexed signer);
    event SignerRemoved(address indexed signer);

    constructor(address factory, address registry) {
        require(factory != address(0), "Company: factory cannot be zero address");
        require(registry != address(0), "Company: registry cannot be zero address");
        companyFactory = ICompanyFactory(factory);
        companyRegistry = ICompanyRegistry(registry);
    }

    receive() external payable {
        emit ReceivedFunds(msg.sender, msg.value);
    }

    function encodeInfo(CompanyInfo memory info) public pure returns (bytes memory) {
        return abi.encode(info);
    }

    function init(address _owner, bytes calldata initData) external onlyCompanyFactory {
        require(!initialized, "Company: already initialized");

        (CompanyInfo memory info) = abi.decode(initData, (CompanyInfo));
        owner = _owner;
        name = info.name;
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        initialized = true;
    }

    function getName() external view override returns (string memory) {
        return name;
    }

    function getOwner() external view override returns (address) {
        return owner;
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

    function upgrade(address newCompany) public onlyCompanyRegistry() {
        require(newCompany != address(0), "Company: new company cannot be zero address");
        if(address(this).balance > 0) {
            payable(newCompany).transfer(address(this).balance);
        }
    }

    function withdraw(uint256 amt) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amt <= address(this).balance, "Company: insufficient balance");
        payable(owner).transfer(amt);
    }

    function withdrawToken(address token, uint256 amt) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(IERC20(token).balanceOf(address(this)) >= amt, "Company: insufficient token balance");
        IERC20(token).transfer(owner, amt);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICompanyFactory} from "./ICompanyFactory.sol";
import {IBasicCompany} from "./ICompany.sol";
import {IWorld} from "../world/IWorld.sol";
import {LibStringCase} from '../LibStringCase.sol';


contract CompanyRegistry {
    using LibStringCase for string;
    ICompanyFactory public companyFactory;

    mapping (string => address) public companiesByName;
    mapping (address => address) public companiesByAddress;
    mapping (address => address) public companiesRegisteredByWorldAddress;

    modifier onlyWorldSigner(address world) {
        require(IWorld(world).isSigner(msg.sender), "CompanyRegistry: invalid world signer");
        _;
    }
    
    event CompanyRegistered(address indexed company, address indexed owner, address world);
    event CompanyCreated(address indexed company, address indexed owner);

    constructor(ICompanyFactory _companyFactory) {
        companyFactory = _companyFactory;
    }

    function isCompany(address company) external view returns (bool) {
        return companiesByAddress[company] != address(0);
    }

    function createCompany(address owner, bytes calldata initData) external returns (address company) {
        // create the company
        company = companyFactory.createCompany(owner, initData);
        require(company != address(0), "CompanyRegistry: failed to create company");
        string memory nm = IBasicCompany(company).getName().lower();
        require(companiesByName[nm] == address(0), "CompanyRegistry: company already exists");
        companiesByName[nm] = company;
        companiesByAddress[company] = company;
        emit CompanyCreated(company, owner);
    }

    function register(
        address world,
        address company,
        bool tokensToOwner
        ) external onlyWorldSigner(world) payable {
        
        // register the company address to the world
        companiesRegisteredByWorldAddress[world] = company;

        address _owner = IBasicCompany(company).getOwner();

        if (msg.value > 0) {
            if (tokensToOwner) {
                payable(_owner).transfer(msg.value);
            } else {
                payable(address(company)).transfer(msg.value);
            }
        }

        emit CompanyRegistered(company, _owner, world);
    }
    function upgradeCompany(address oldCompany, address _owner, bytes calldata initData) external {

        require(this.isCompany(oldCompany), "CompanyRegistry: invalid company");

        bool isSigner = IBasicCompany(oldCompany).isSigner(msg.sender);
        require(isSigner, "CompanyRegistry: invalid owner");

        address newCompany = companyFactory.createCompany(_owner, initData);
        require(newCompany != address(0x0), "CompanyRegistry: failed to create company");

        delete companiesByAddress[oldCompany];
        companiesByAddress[newCompany] = newCompany;

        delete companiesByName[IBasicCompany(oldCompany).getName().lower()];

        string memory nm = IBasicCompany(newCompany).getName().lower();
        require(companiesByName[nm] == address(0x0), "CompanyRegistry: company already exists");
        companiesByName[nm] = newCompany;

        IBasicCompany(oldCompany).upgrade(newCompany);
    }
}
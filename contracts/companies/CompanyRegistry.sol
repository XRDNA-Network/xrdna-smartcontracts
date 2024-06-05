// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICompanyFactory} from "./ICompanyFactory.sol";
import {IBasicCompany} from "./ICompany.sol";
import {IWorld} from "../world/IWorld.sol";

contract CompanyRegistry {

    ICompanyFactory public companyFactory;

    mapping (string => address) public companiesByName;
    mapping (string => address) public companiesByVectorAddress;
    mapping (address => string) public companiesByAddress;

    modifier onlyWorldSigner(address world, address worldSigner) {
        require(IWorld(world).isSigner(worldSigner), "CompanyRegistry: invalid world signer");
        _;
    }
    
    event CompanyRegistered(address indexed company, address indexed owner, VectorAddress vectorAddress);

    constructor(ICompanyFactory _companyFactory) {
        companyFactory = _companyFactory;
    }

    function isCompany(address company) external view returns (bool) {
        return companiesByAddress[company] != address(0);
    }

    function register(
        address world,
        address worldSigner,
        address _owner,
        bytes calldata initData,
        bool tokensToOwner
        ) external onlyWorldSigner(world, worldSigner) payable {
        // Create the company
        address c = companyFactory.createCompany(_owner, initData);
        require(c != address(0), "CompanyRegistry: failed to create company");
        
        string memory nm = IBasicCompany(c).getName().lower();
        require(companiesByName[nm] == address(0), "CompanyRegistry: company already exists");

        companiesByName[nm] = c;
        companiesByAddress[c] = c;
        companiesByVectorAddress[IBasicCompany(c).getBaseVector().toString()] = c;

        if (msg.value > 0) {
            if (tokensToOwner) {
                payable(_owner).transfer(msg.value);
            } else {
                payable(address(c)).transfer(msg.value);
            }
        }

        emit CompanyRegistered(c, _owner, IBasicCompany(c).getBaseVector());
    }
    function upgradeCompany(address world, address worldSigner, address oldCompany, bytes calldata initData) external onlyWorldSigner(world, worldSigner) {
        require(isCompany(oldCompany), "CompanyRegistry: invalid company");
        address owner = IBasicCompany(oldCompany).getOwner();
        address newCompany = companyFactory.createCompany(owner, initData);
        require(newCompany != address(0x0), "CompanyRegistry: failed to create company");

        delete companiesByAddress[oldCompany];
        companiesByAddress[newCompany] = newCompany;

        delete companiesByVectorAddress[IBasicCompany(oldCompany).getBaseVector().asLookupKey()];
        companiesByVectorAddress[IBasicCompany(newCompany).getBaseVector().asLookupKey()] = newCompany;

        delete companiesByName[IBasicCompany(oldCompany).getName().lower()];

        string memory nm = IBasicCompany(newCompany).getName().lower();
        require(companiesByName[nm] == address(0x0), "CompanyRegistry: company already exists");
        companiesByName[nm] = newCompany;

        IBasicCompany(oldCompany).upgrade(newCompany);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {EntityShell} from '../../base-types/EntityShell.sol';
import {IExtensionResolver} from '../../interfaces/IExtensionResolver.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {IRegistrarRegistry} from '../../registrar/registry/IRegistrarRegistry.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {CommonInitArgs} from '../../interfaces/entity/IRegisteredEntity.sol';
import {RegistrationTerms} from '../../libraries/LibTypes.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibVectorAddress, VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';

struct CompanyConstructorArgs {
    address extensionResolver;
    address owningRegistry;
    address worldRegistry;
}

contract Company  is EntityShell {
    
    using LibVectorAddress for VectorAddress;

    ICompanyRegistry public immutable companyRegistry;
    IWorldRegistry public immutable worldRegistry;
    //TODO: add experience registry
    
    modifier onlyRegistry {
        require(msg.sender == address(worldRegistry), "Company: only world registry");
        _;
    }

    constructor(CompanyConstructorArgs memory args) EntityShell(IExtensionResolver(args.extensionResolver)) {
        
        require(args.owningRegistry != address(0), "Company: owningRegistry cannot be zero address");
        require(args.worldRegistry != address(0), "Company: worldRegistry cannot be zero address");
        worldRegistry = IWorldRegistry(args.owningRegistry);        
        companyRegistry = ICompanyRegistry(args.owningRegistry);
    }

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
    }   

    function name() external view returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function init(CommonInitArgs calldata args) external onlyRegistry {
        require(args.termsOwner != address(0), "Company: terms owner is the zero address");
        require(bytes(args.name).length > 0, "Company: name cannot be empty");

        address[] memory admins = new address[](0);
        LibAccess.initAccess(args.owner, admins);

        //true, false means must have a p value > 0 and p_sub == 0
        args.vector.validate(true, false);
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
        rs.vector = args.vector;
        rs.termsOwner = args.termsOwner;
    }

    function vectorAddress() external view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }

    function world() external view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }   
}
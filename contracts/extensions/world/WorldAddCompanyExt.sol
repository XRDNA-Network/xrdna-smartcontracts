// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibFactory} from '../../libraries/LibFactory.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {IWorldAddCompany, NewCompanyArgs} from '../../interfaces/world/IWorldAddCompany.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {CreateEntityArgs} from '../../interfaces/registry/IRegistration.sol';
import {IRegistrar} from '../../registrar/instance/IRegistrar.sol';
import {IWorldRegistry} from '../../world/registry/IWorldRegistry.sol';
import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {IWorld} from '../../world/instance/IWorld.sol';
import {ICompanyRegistry, CreateCompanyArgs} from '../../company/registry/ICompanyRegistry.sol';
import {LibWorld, WorldStorage} from '../../world/instance/LibWorld.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import "hardhat/console.sol";

contract WorldAddCompanyExt is IExtension, IWorldAddCompany {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "FactoryExt: restricted to admins");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "FactoryExt: restricted to signers");
        _;
    }
     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.WORLD_ADD_COMPANY,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](4);

        sigs[0] = SelectorInfo({
            selector: this.registerCompany.selector,
            name: "registerWorld(NewCompanyArgs)"
        });
        sigs[1] = SelectorInfo({
            selector: this.deactivateCompany.selector,
            name: "deactivateCompany(address,string)"
        });
        sigs[2] = SelectorInfo({
            selector: this.reactivateCompany.selector,
            name: "reactivateCompany(address)"
        });
        sigs[3] = SelectorInfo({
            selector: this.removeCompany.selector,
            name: "removeCompany(address,string)"
        });
       
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no-op
    }

    /**
     * Initialize any storage related to the extension
     */
    function initStorage(ExtensionInitArgs calldata args) external {
        //nothing to initialize
    }


    /**
     * @dev Registers a new company contract. Must be called by a world signer
     */
    function registerCompany(NewCompanyArgs memory args) external payable onlySigner returns (address company) {
        address a = IWorld(address(this)).companyRegistry();
        require(a != address(0), "WorldAddCompanyExt: company registry not set");
        ICompanyRegistry companyRegistry = ICompanyRegistry(a); 
        VectorAddress memory base = IWorld(address(this)).baseVector();
        WorldStorage storage ws = LibWorld.load();
        ++ws.nextPValue;
        base.p = ws.nextPValue;
        console.log("P value", base.p);

        company = companyRegistry.createCompany(CreateCompanyArgs({
            sendTokensToOwner: args.sendTokensToOwner,
            owner: args.owner,
            name: args.name,
            terms: args.terms,
            initData: args.initData,
            ownerTermsSignature: args.ownerTermsSignature,
            expiration: args.expiration,
            vector: base
        }));

        emit IWorld.WorldAddedCompany(company, args.owner, base);

    }

    /**
     * @dev Deactivates a company contract. Must be called by a world signer
     */
    function deactivateCompany(address world, string calldata reason) external onlySigner {
        ICompanyRegistry registry = ICompanyRegistry(IWorld(address(this)).companyRegistry());
        registry.deactivateEntity(IRemovableEntity(world), reason);
    }

    /**
     * @dev Reactivates a company contract. Must be called by a world signer
     */
    function reactivateCompany(address world) external onlySigner {
        ICompanyRegistry registry = ICompanyRegistry(IWorld(address(this)).companyRegistry());
        registry.reactivateEntity(IRemovableEntity(world));
    }

    /**
     * @dev Removes a company contract. Must be called by a world signer
     */
    function removeCompany(address world, string calldata reason) external onlySigner {
        ICompanyRegistry registry = ICompanyRegistry(IWorld(address(this)).companyRegistry());
        registry.removeEntity(IRemovableEntity(world), reason);
    }

}
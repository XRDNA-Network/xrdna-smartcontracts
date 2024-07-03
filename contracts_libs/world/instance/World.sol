// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from "../../base-types/entity/BaseRemovableEntity.sol";
import {BaseEntityConstructorArgs} from "../../base-types/entity/BaseEntity.sol";
import {IWorld} from "../interfaces/IWorld.sol";
import {IWorldRegistry} from "../interfaces/IWorldRegistry.sol";
import {VectorAddress} from '../../core-libs/LibVectorAddress.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';
import {LibWorld} from '../libs/LibWorld.sol';
import {LibRemovableEntity} from '../../entity-libs/removal/LibRemovableEntity.sol';
import {LibAccess} from '../../core-libs/LibAccess.sol';
import {LibFundable} from '../../core-libs/LibFundable.sol';
import {Version} from '../../core-libs/LibTypes.sol';
import {CommonInitArgs} from '../../entity-libs/interfaces/IRegisteredEntity.sol';

struct WorldConstructorArgs {
    address owningRegistry;
    //address companyRegistry;
    //address avatarRegistry;
}


contract World is BaseRemovableEntity, IWorld {


    //ICompanyRegistry public override companyRegistry;
    //IAvatarRegistry public override avatarRegistry;

    constructor(WorldConstructorArgs memory args) BaseRemovableEntity(BaseEntityConstructorArgs({
        owningRegistry: args.owningRegistry})) {
            /*
        require(args.companyRegistry != address(0), "World: companyRegistry cannot be the zero address");
        require(args.avatarRegistry != address(0), "World: avatarRegistry cannot be the zero address");
        companyRegistry = ICompanyRegistry(args.companyRegistry);
        avatarRegistry = IAvatarRegistry(args.avatarRegistry);
        */
    }

    function name() external view override returns (string memory) {
        return LibRemovableEntity.load().name;
    }

    function init(CommonInitArgs memory args) public override {
        LibWorld.initWorld(args);
    }

    function termsOwner() external view override returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }
    
    function getBaseVector() external view override returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }

    function upgrade(bytes calldata data) external override onlyAdmin {
        IWorldRegistry(owningRegistry).upgradeEntity(data);
    }

    function postUpgradeInit(bytes calldata data) external override onlyAdmin {
       //no-op until future version available
    }


     /**
     * @dev Deactivates a company contract. Must be called by a world signer
     */
    function deactivateCompany(address company, string calldata reason) external onlySigner {
        //TODO
    }

    /**
     * @dev Reactivates a company contract. Must be called by a registrar signer
     */
    function reactivateCompany(address company) external onlySigner {
        //TODO
    }

    /**
     * @dev Removes a company contract. Must be called by a registrar signer
     */
    function removeCompany(address company, string calldata reason) external onlySigner {
       //TODO
    }

    function changeTermsOwner(address owner) external override onlyRegistry {
        LibRemovableEntity.load().termsOwner = owner;
        emit TermsOwnerChanged(owner);
    }

    function isStillActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isTermsOwnerSigner(address a) external view returns (bool) {
        return LibAccess.isSigner(a);
    }

    function withdraw(uint256 amount) external override onlyOwner {
        LibFundable.withdraw(amount);
    }
}
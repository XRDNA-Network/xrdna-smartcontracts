// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRegistrar, CreateWorldArgs} from "./IRegistrar.sol";
import {BaseRemovableEntity} from '../../entity/BaseRemovableEntity.sol';
import {BaseEntityConstructorArgs} from "../../entity/BaseEntity.sol";
import {ModuleVersion} from "../../modules/IModule.sol";
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibEntity, EntityStorage} from '../../libraries/LibEntity.sol';
import {RegistrationTerms} from '../../modules/registration/IRegistration.sol';
import {LibRegistrarTerms} from './LibRegistrarTerms.sol';
import {LibFunds} from '../../libraries/LibFunds.sol';

contract Registrar is BaseRemovableEntity, IRegistrar {

    string public constant override name = "Registrar";


    constructor(BaseEntityConstructorArgs memory args) BaseRemovableEntity(args) {}


    function version() external pure override returns (ModuleVersion memory) {
        return ModuleVersion(1, 0);
    }

    function init(address owner, string calldata nm, bytes calldata initData) public override {
        EntityStorage storage e = LibEntity.load();
        require(e.owner == address(0), "Registrar: already initialized");
        require(owner != address(0), "Registrar: owner cannot be zero address");
        require(bytes(nm).length > 0, "Registrar: name cannot be empty");
        e.owner = owner;
        e.name = nm;
        RegistrationTerms memory terms = abi.decode(initData, (RegistrationTerms));
        LibRegistrarTerms.load().worldTerms = terms;
        LibAccess.initAccess(owner, new address[](0));
    }

    function upgrade(bytes calldata data) external override onlyAdmin {
        owningRegistry.upgradeEntity(data);
    }

    function postUpgradeInit(bytes calldata data) external override onlyAdmin {
       //no-op until future version available
    }

    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(CreateWorldArgs memory args) external payable onlySigner returns (address world)  {
        //TODO: implement
    }

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world) external onlySigner {
        //TODO: implement
    }

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external onlySigner {
        //TODO: implement
    }

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world) external onlySigner {
        //TODO: implement
    }

    function setTerms(RegistrationTerms calldata terms) external onlyAdmin {
        LibRegistrarTerms.load().worldTerms = terms;
    }
    function getTerms() external view returns (RegistrationTerms memory) {
        return LibRegistrarTerms.load().worldTerms;
    }

    function isStillActive() external view returns (bool) {
        return LibEntity.load().active;
    }

    function isTermsOwnerSigner(address a) external view returns (bool) {
        return LibAccess.isSigner(a);
    }

    function withdraw(uint256 amount) external override onlyOwner {
        LibFunds.withdraw(amount);
    }
}
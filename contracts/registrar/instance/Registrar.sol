// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseRemovableEntity} from '../../base-types/entity/BaseRemovableEntity.sol';
import {IRegistrar, NewWorldArgs, RegistrarInitArgs} from './IRegistrar.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../libraries/LibRemovableEntity.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {Version} from '../../libraries/LibTypes.sol';

contract Registrar is BaseRemovableEntity, IRegistrar {

    address public immutable registrarRegistry;

    constructor(address _registrarRegistry) {
        require(_registrarRegistry != address(0), 'Registrar: Invalid registrar registry');
        registrarRegistry = _registrarRegistry;
    }

    function version() external pure override returns (Version memory) {
        return Version(1, 0);
    }

    function owningRegistry() internal view override returns (address) {
        return registrarRegistry;
    }


    function init(string calldata name, bytes calldata initData) external onlyRegistry {
        LibEntity.load().name = name;
        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.termsOwner = msg.sender;
        RegistrarInitArgs memory args = abi.decode(initData, (RegistrarInitArgs));
        LibAccess.initAccess(args.owner, args.admins);
    }


    /**
     * @dev Registers a new world contract. Must be called by a registrar signer
     */
    function registerWorld(NewWorldArgs memory args) external payable  onlySigner  returns (address world){

    }

    /**
     * @dev Deactivates a world contract. Must be called by a registrar signer
     */
    function deactivateWorld(address world, string calldata reason) external onlySigner {

    }

    /**
     * @dev Reactivates a world contract. Must be called by a registrar signer
     */
    function reactivateWorld(address world) external onlySigner {

    }

    /**
     * @dev Removes a world contract. Must be called by a registrar signer
     */
    function removeWorld(address world, string calldata reason) external onlySigner {

    }


    function isStillActive() external view returns (bool) {
        return LibRemovableEntity.load().active;
    }

    function isTermsOwnerSigner(address a) external view returns (bool) {
        return isSigner(a);
    }
}
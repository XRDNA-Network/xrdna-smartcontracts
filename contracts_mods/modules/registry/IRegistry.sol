// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ChangeEntityTermsArgs} from '../registration/IRegistration.sol';
import {IEntityRemoval} from '../entity/removal/IEntityRemoval.sol';

interface IRegistry is IEntityRemoval {
    
    function isRegistered(address addr) external view returns (bool);
    function getEntityByName(string calldata name) external view returns (address);

    /**
     * @dev Entity owner can request to upgrade the entity to a new version. This function is called
     * by the entity contract itself.
     */
    function upgradeEntity(bytes calldata data) external;

    /**
     * @dev called by the entity's terms controller to change the terms of the entity. This requires a 
     * signature from an entity signer to authorize the change. The signature is a hash of the terms
     * fees, coverage period, grace period, and an expiration time for the signature.
     */
    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external;
}
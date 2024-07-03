// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Version} from '../../core-libs/LibTypes.sol';
import {IAccessControl} from '../IAccessControl.sol';
import {IEntityRemoval} from '../../entity-libs/interfaces/IEntityRemoval.sol';
import {ChangeEntityTermsArgs} from '../../entity-libs/interfaces/IRegistration.sol';
import {RegistrationTerms} from '../../core-libs/LibTypes.sol';

struct CreateEntityArgs {
    bool sendTokensToOwner;
    address owner;
    string name;
    RegistrationTerms terms;
    bytes initData;
    bytes ownerTermsSignature;
    uint256 expiration;
}

interface IRegistry is IAccessControl, IEntityRemoval{

    event ProxyImplementationSet(address newImpl);
    event EntityImplementationSet(address newImpl, Version version);
    event RegistryAddedEntity(address indexed entity, address indexed owner);
    event RegistryUpgradedEntity(address indexed old, address newVersion);

    function setProxyImplementation(address newImpl) external;
    function proxyImplementation() external view returns (address);

    function setEntityImplementation(address newImpl) external;

    function entityImplementation() external view returns (address);
    function version() external pure returns (Version memory);

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

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IRegistration} from '../../interfaces/registry/IRegistration.sol';
import {IRegistryFactory} from '../../interfaces/registry/IRegistryFactory.sol';
import {IAccessControl} from '../../interfaces/IAccessControl.sol';

struct CreateAssetArgs {
    address owner;
    string name;
    bytes initData;
}

interface IAssetRegistry is IRegistration, IRegistryFactory, IAccessControl {
    
   
    /**
     * @dev Determines if the asset from the original chain has been registered
     */
    function assetExists(address original, uint256 chainId) external view returns (bool);


    /**
     * @dev Registers a new asset with the registry. Only callable by the registry admin
     * after verifying ownership by the issuing company.
     */
    function registerAsset(bytes calldata initData) external returns (address asset);

    function deactivateAsset(address asset, string calldata reason) external;

    function reactivateAsset(address asset) external;

    /**
     * @dev Removes an asset from the registry. Only callable by the registry admin
     */
    function removeAsset(address asset, string calldata reason) external;
}
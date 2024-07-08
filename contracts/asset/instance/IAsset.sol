// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableEntity} from '../../interfaces/entity/IRemovableEntity.sol';
import {AssetCheckArgs} from '../IAssetCondition.sol';
import {IAssetRegistry} from '../registry/IAssetRegistry.sol';


struct AssetInitArgs {
    string name; 
    string symbol;
    address issuer; 
    address originAddress;
    uint256 originChainId;
    bytes initData;
}

interface IAsset is IRemovableEntity {

    event AssetConditionSet(address condition);
    event AssetConditionRemoved();

    function init(AssetInitArgs calldata args) external;

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    function issuer() external view returns (address);

    function originAddress() external view returns (address);

    function originChainId() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function approve(address, uint256) external returns (bool); 

    
    function transferFrom(address, address, uint256) external returns (bool);

    function setCondition(address condition) external;
    function removeCondition() external;
    function canViewAsset(AssetCheckArgs memory args) external view returns (bool);
    function canUseAsset(AssetCheckArgs memory args) external view returns (bool);

}
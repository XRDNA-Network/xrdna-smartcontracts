// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ReentrancyGuard} from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import {IExtension, ExtensionMetadata} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {IAsset} from '../../asset/IAsset.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {IAssetCondition, AssetCheckArgs} from '../../interfaces/asset/IAssetCondition.sol';
import {LibAsset, AssetStorage} from '../../libraries/LibAsset.sol';

contract AssetConditionExt is IExtension {

    
    modifier onlyIssuer() {
        address i = LibAsset.load().issuer;
        require(msg.sender == i, "BaseAsset: only issuer allowed");
        require(IAsset(address(this)).companyRegistry().isRegistered(i), "BaseAsset: issuer is not a registered company");
        require(ICompany(i).isEntityActive(), "BaseAsset: issuer is not active");
       _;
    }

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.ASSET_CONDITION,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](6);
        
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


    function setCondition(address condition) public onlyIssuer {
        require(condition != address(0), "BaseAsset: condition cannot be zero address");
        LibAsset.load().condition = IAssetCondition(condition);
        emit IAsset.AssetConditionSet(address(condition));
    }

    function removeCondition() public onlyIssuer {
        delete LibAsset.load().condition;
        emit IAsset.AssetConditionRemoved();
    }

    
    function canViewAsset(AssetCheckArgs memory args) public view returns (bool) {
        AssetStorage storage s = LibAsset.load();
        if (address(s.condition) == address(0)) {
            return true;
        }
        return s.condition.canView(args);
    }

    function canUseAsset(AssetCheckArgs memory args) public view returns (bool) {
        AssetStorage storage s = LibAsset.load();
        if (address(s.condition) == address(0)) {
            return true;
        }
        return s.condition.canUse(args);
    }

   
}
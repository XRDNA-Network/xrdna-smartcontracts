// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetFactory, AssetType} from "./IAssetFactory.sol";
import {BaseFactory} from "../BaseFactory.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {IBaseProxy} from "../IBaseProxy.sol";

interface IBasicAsset {
    function init(bytes memory data) external;
}

contract AssetFactory is BaseFactory, IAssetFactory {

    address erc20Implementation;
    address erc20ProxyImplementation;
    address erc721Implementation;
    address erc721ProxyImplementation;

   
    constructor(address mainAdmin, address[] memory admins) BaseFactory(mainAdmin, admins) {}
        
    function setERC20Implementation(address impl) external onlyRole(ADMIN_ROLE) {
        require(impl != address(0), "AssetFactory: zero address not valid");
        erc20Implementation = impl;
    }

    function setERC721Implementation(address impl) external onlyRole(ADMIN_ROLE) {
        require(impl != address(0), "AssetFactory: zero address not valid");
        erc721Implementation = impl;
    }

    function setERC20ProxyImplementation(address impl) external onlyRole(ADMIN_ROLE) {
        require(impl != address(0), "AssetFactory: zero address not valid");
        erc20ProxyImplementation = impl;
    }

    function setERC721ProxyImplementation(address impl) external onlyRole(ADMIN_ROLE) {
        require(impl != address(0), "AssetFactory: zero address not valid");
        erc721ProxyImplementation = impl;
    }

    function createAsset(uint256 assetType, bytes calldata initData) external  onlyAuthorizedRegistry override returns (address proxy) {
        require(assetType > 0 && assetType <= uint256(type(AssetType).max), "AssetFactory: invalid asset type");
        require(erc20Implementation != address(0) && erc721Implementation != address(0), "AssetFactory: implementations not set");

        AssetType at = AssetType(assetType);
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        address target = at == AssetType.ERC20 ? erc20Implementation : erc721Implementation;
        address tgtProxy = at == AssetType.ERC20 ? erc20ProxyImplementation : erc721ProxyImplementation;
        address asset  = create(target);
        proxy = create(tgtProxy);
        IBaseProxy(proxy).initProxy(asset);
        IBasicAsset(proxy).init(initData);
        //console.log("Calling proxy.init", address(this));
    }
}
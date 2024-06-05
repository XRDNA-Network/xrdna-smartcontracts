// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetFactory, AssetType} from "./IAssetFactory.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IBasicAsset {
    function init(bytes memory data) external;
}

contract AssetFactory is IAssetFactory, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address assetRegistry;
    address erc20Implementation;
    address erc721Implementation;

    modifier onlyRegistry() {
        require(assetRegistry != address(0), "AssetFactory: registry not set");
        require(msg.sender == assetRegistry, "AssetFactory: only registry allowed");
        _;
    }

    constructor(address[] memory admins) {
        for (uint256 i = 0; i < admins.length; i++) {
            require(admins[i] != address(0), "AssetFactory: admin address cannot be 0");
            require(_grantRole(ADMIN_ROLE, admins[i]), "AssetFactory: admin role grant failed");
        }
    }

    function setAssetRegistry(address registry) external onlyRole(ADMIN_ROLE) {
        require(registry != address(0), "AssetFactory: zero address not valid");
        assetRegistry = registry;
    }

    function setERC20Implementation(address impl) external onlyRole(ADMIN_ROLE) {
        require(impl != address(0), "AssetFactory: zero address not valid");
        erc20Implementation = impl;
    }

    function setERC721Implementation(address impl) external onlyRole(ADMIN_ROLE) {
        require(impl != address(0), "AssetFactory: zero address not valid");
        erc721Implementation = impl;
    }

    function createAsset(uint256 assetType, bytes calldata initData) external  onlyRegistry() override returns (address proxy) {
        require(assetType > 0 && assetType <= uint256(type(AssetType).max), "AssetFactory: invalid asset type");
        require(erc20Implementation != address(0) && erc721Implementation != address(0), "AssetFactory: implementations not set");

        AssetType at = AssetType(assetType);
        // Adapted from https://github.com/optionality/clone-factory/blob/32782f82dfc5a00d103a7e61a17a5dedbd1e8e9d/contracts/CloneFactory.sol
        bytes20 targetBytes = bytes20(at == AssetType.ERC20 ? erc20Implementation : erc721Implementation);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            proxy := create(0, clone, 0x37)
        }
        IBasicAsset(proxy).init(initData);
        //console.log("Calling proxy.init", address(this));
    }

    function isAssetClone(AssetType assetType, address query) public view returns (bool result) {
        address target = assetType == AssetType.ERC20 ? erc20Implementation : erc721Implementation;
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
            mstore(add(clone, 0xa), targetBytes)
            mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}
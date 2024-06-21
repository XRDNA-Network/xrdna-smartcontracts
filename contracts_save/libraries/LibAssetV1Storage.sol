// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetCondition} from '../asset/IAssetCondition.sol';

/**
 * In order to support upgrading assets, each asset version must have its own 
 * storage struct stored in a slot determined by its version. This library
 * allows us to easily access the storage for any past version of an asset.
 */


//attributes common to any asset
struct CommonAssetV1Storage {
    uint8 decimals;

    //the contract address on the origin chain
    address originAddress;

    //the address allowed to mint new tokens
    address issuer;

    //custom view/use conditions
    IAssetCondition condition;

    //original chain id
    uint256 originChainId;
    
    string name;

    string symbol;
}

//storage specific to ERC20 version1 contract
struct ERC20V1Storage {
    uint256 maxSupply;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    CommonAssetV1Storage attributes;
}

//storage specific to ERC721 version1 contract
struct ERC721V1Storage {
    string baseURI;
    uint256 tokenIdCounter;
    mapping(uint256 => address) owners;
    mapping(address => uint256) balances;
    mapping(uint256 => address) tokenApprovals;

    mapping(address => mapping(address => bool)) operatorApprovals;
    CommonAssetV1Storage attributes;
}

/**
 * @title LibAssetV1Storage
 * @dev Storage library for accessing storage slots of version 1 assets
 */
library LibAssetV1Storage {
    bytes32 public constant ERC20_STORAGE_SLOT = keccak256("_ERC20V1Storage");
    bytes32 public constant ERC712_STORAGE_SLOT = keccak256("_ERC712V1Storage");

    /**
     * @dev Load the storage struct for the ERC20 V1 contract
     */
    function loadERC20Storage() internal pure returns (ERC20V1Storage storage s) {
        bytes32 slot = ERC20_STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }

    /**
     * @dev Load the storage struct for the ERC721 V1 contract
     */
    function loadERC721Storage() internal pure returns (ERC721V1Storage storage s) {
        bytes32 slot = ERC712_STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }
}
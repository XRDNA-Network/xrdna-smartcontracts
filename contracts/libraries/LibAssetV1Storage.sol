// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IAssetHook} from '../asset/IAssetHook.sol';
import {IAssetCondition} from '../asset/IAssetCondition.sol';

struct CommonAssetV1Storage {
    uint8 decimals;

    //the contract address on the origin chain
    address originAddress;

    //the address allowed to mint new tokens
    address issuer;

    //custom mint/transfer behavior
    IAssetHook hook;

    //custom view/use conditions
    IAssetCondition condition;

    //original chain id
    uint256 originChainId;
    
    string name;

    string symbol;
}

struct ERC20V1Storage {
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    CommonAssetV1Storage attributes;
}

struct ERC721V1Storage {
    string baseURI;
    uint256 tokenIdCounter;
    mapping(uint256 => address) owners;
    mapping(address => uint256) balances;
    mapping(uint256 => address) tokenApprovals;

    mapping(address => mapping(address => bool)) operatorApprovals;
    CommonAssetV1Storage attributes;
}

library LibAssetV1Storage {
    bytes32 public constant ERC20_STORAGE_SLOT = keccak256("_ERC20Storage");
    bytes32 public constant ERC712_STORAGE_SLOT = keccak256("_ERC712Storage");

    function loadERC20Storage() internal pure returns (ERC20V1Storage storage s) {
        bytes32 slot = ERC20_STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }

    function loadERC721Storage() internal pure returns (ERC721V1Storage storage s) {
        bytes32 slot = ERC712_STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }
}
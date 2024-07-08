// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseAsset, BaseAssetConstructorArgs} from '../../BaseAsset.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {CommonInitArgs} from '../../../interfaces/entity/IRegisteredEntity.sol';
import {IAvatar} from '../../../avatar/instance/IAvatar.sol';
import {LibRemovableEntity, RemovableEntityStorage} from '../../../libraries/LibRemovableEntity.sol';
import {LibAsset, AssetStorage} from '../../../libraries/LibAsset.sol';
import {LibERC20, ERC20Storage} from '../../../libraries/LibERC20.sol';

struct ERC20InitData {
    //the address of the original asset on the origin chain
    address originChainAddress;

    //the number of decimal places for the token
    uint8 decimals;

    //the chain id of the origin chain
    uint256 originChainId;

    //maximum supply, set to type(uint256).max for unlimited supply
    uint256 maxSupply;

    //the symbol of the token
    string symbol;
}

contract NTERC20Asset is BaseAsset {
    
    constructor(BaseAssetConstructorArgs memory args) BaseAsset(args) {
    }

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
    }

    function init(CommonInitArgs calldata args) external onlyRegistry {

        AssetStorage storage store = LibAsset.load();
        ERC20Storage storage erc20Store = LibERC20.load();
        require(store.issuer == address(0), "NTERC20Asset: already initialized");

        require(args.owner != address(0), "NTERC20Asset: owner cannot be zero address");
        require(args.termsOwner != address(0), "NTERC20Asset: terms owner cannot be zero address");
        require(args.registry != address(0), "NTERC20Asset: registry cannot be zero address");
        require(bytes(args.name).length > 0, "NTERC20Asset: name cannot be empty");
        ERC20InitData memory initData = abi.decode(args.initData, (ERC20InitData));
        require(initData.decimals > 0, "NTERC20Asset: decimals must be greater than zero");
        require(initData.originChainAddress != address(0), "NTERC20Asset: origin chain address cannot be zero address");
        require(initData.originChainId > 0, "NTERC20Asset: origin chain id must be greater than zero");
        require(initData.maxSupply > 0, "NTERC20Asset: max supply must be greater than zero");
        require(bytes(initData.symbol).length > 0, "NTERC20Asset: symbol cannot be empty");
        
        store.issuer = args.owner;
        store.originAddress = initData.originChainAddress;
        store.originChainId = initData.originChainId;
        store.symbol = initData.symbol;
        erc20Store.maxSupply = initData.maxSupply;
        erc20Store.decimals = initData.decimals;

        RemovableEntityStorage storage rs = LibRemovableEntity.load();
        rs.active = true;
        rs.name = args.name;
    }

    


     
    
}

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseAsset, BaseAssetConstructorArgs} from '../../BaseAsset.sol';
import {Version} from '../../../libraries/LibTypes.sol';
import {CommonInitArgs} from '../../../interfaces/entity/IRegisteredEntity.sol';

import {AssetStorage, LibAsset} from '../../../libraries/LibAsset.sol';
import {ERC721Storage, LibERC721} from '../../../libraries/LibERC721.sol';
import {IAvatar} from '../../../avatar/instance/IAvatar.sol';
import {IERC721Asset} from './IERC721Asset.sol';
import {LibRemovableEntity} from '../../../libraries/LibRemovableEntity.sol';
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';


struct ERC721InitData {

    //origin chain address of the asset
    address originChainAddress;

    //origin chain id of the asset
    uint256 originChainId;

    //standard ERC721 fields
    string symbol;

    //baseURI cannot be empty
    string baseURI;
}

contract NTERC721Asset is BaseAsset {

    using Strings for uint256;

    constructor(BaseAssetConstructorArgs memory _args) BaseAsset(_args) {}

    function version() external pure returns (Version memory) {
        return Version({
            major: 1,
            minor: 0
        });
    }

    function init(CommonInitArgs calldata args) external onlyRegistry {
        AssetStorage storage store = LibAsset.load();
        ERC721Storage storage ercStore = LibERC721.load();
        require(store.issuer == address(0), "NTERC721Asset: already initialized");

        require(args.owner != address(0), "NTERC721Asset: owner cannot be zero address");
        require(args.termsOwner != address(0), "NTERC721Asset: terms owner cannot be zero address");
        require(args.registry != address(0), "NTERC721Asset: registry cannot be zero address");
        require(bytes(args.name).length > 0, "NTERC721Asset: name cannot be empty");
        ERC721InitData memory initData = abi.decode(args.initData, (ERC721InitData));
        require(bytes(initData.baseURI).length > 0, "NTERC721Asset: base URI must be set");
        require(initData.originChainAddress != address(0), "NTERC721Asset: origin chain address cannot be zero address");
        require(initData.originChainId > 0, "NTERC721Asset: origin chain id must be greater than zero");
        require(bytes(initData.symbol).length > 0, "NTERC721Asset: symbol cannot be empty");
        require(bytes(initData.symbol).length > 0, "NTERC721Asset: symbol cannot be empty");
        
        store.issuer = args.owner;
        store.name = args.name;
        store.originAddress = initData.originChainAddress;
        store.originChainId = initData.originChainId;
        store.symbol = initData.symbol;
        //beause the tokenURI function assumes a trailing '/', we need to add it
        //if it doesn't exist
        if(!_endsWith(initData.baseURI, "/")) {
            ercStore.baseURI = string.concat(initData.baseURI, "/");
        } else {
            ercStore.baseURI = initData.baseURI;
        }

        LibRemovableEntity.load().active = true;
    }

    //internal helper to verify that the string ends with a suffix value
    function _endsWith(string memory str, string memory suffix) internal pure returns (bool) {
        return bytes(str).length >= bytes(suffix).length && bytes(str)[bytes(str).length - bytes(suffix).length] == bytes(suffix)[0];
    }
    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {LibAsset} from '../../libraries/LibAsset.sol';

abstract contract BaseInfoExt is IExtension {

    function symbol() public view returns (string memory) {
        return LibAsset.load().symbol;
    } 

    function issuer() public view returns (address) {
        return LibAsset.load().issuer;
    }

    function originAddress() public view returns(address) {
        return LibAsset.load().originAddress;
    }

    function originChainId() public view returns(uint256) {
        return LibAsset.load().originChainId;
    }
}
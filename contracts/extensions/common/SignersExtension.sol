// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibMixin} from "../../libraries/common/LibMixin.sol";
import {LibSigners} from "../../libraries/common/LibSigners.sol";
import {BaseExtension} from "./BaseExtension.sol";
import {ISupportsMixins} from "../../interfaces/ISupportsMixins.sol";
import {ISupportsSigners} from "../../interfaces/common/ISupportsSigners.sol";
import {ISupportsOwner} from "../../interfaces/common/ISupportsOwner.sol";

contract SignersExtension is ISupportsMixins, ISupportsSigners {


    modifier onlyOwner {
        require(msg.sender == ISupportsOwner(address(this)).owner(), "SignersExtension: not owner");
        _;
    }

    function mixins() public override pure returns (bytes4[] memory specs) {
        specs = new bytes4[](3);
        specs[0] = this.isSigner.selector;
        specs[1] = this.addSigners.selector;
        specs[2] = this.removeSigners.selector;
    }

    function isSigner(address _signer) external view returns (bool) {
        return LibSigners.isSigner(_signer);
    }

    function addSigners(address[] calldata _signer) external onlyOwner {
        LibSigners.addSigners(_signer);
    }

    function removeSigners(address[] calldata _signer) external onlyOwner {
        LibSigners.removeSigners(_signer);
    }
    
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;
import {LibMixin} from "../../libraries/common/LibMixin.sol";
import {BaseExtension} from "./BaseExtension.sol";
import {ISupportsMixins} from "../../interfaces/ISupportsMixins.sol";
import {ISupportsFunds} from "../../interfaces/common/ISupportsFunds.sol";
import {FundsStorage, LibFunds} from "../../libraries/common/LibFunds.sol";
import "hardhat/console.sol";

contract FundsExtension is BaseExtension, ISupportsFunds, ISupportsMixins {

    modifier onlyOwner {
        FundsStorage storage fs = LibFunds.load();
        require(fs.owner != address(0), "FundsExtension: owner not set");
        require(msg.sender == fs.owner, "FundsExtension: not owner");
        _;
    }

    function mixins() public override pure returns (bytes4[] memory specs) {
        specs = new bytes4[](2);
        specs[0] = this.withdraw.selector;
        specs[1] = this.owner.selector;
    }

    function owner() external view returns (address) {
        return LibFunds.owner();
    }

    function withdraw(uint256 amount) external onlyOwner {
        LibFunds.withdraw(amount);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibAccess} from './LibAccess.sol';

library LibFundable {

    function withdraw(uint256 amount) internal {
        address owner = LibAccess.owner();
        require(owner == msg.sender, "FundsModule: caller is not the owner");
        require(address(this).balance >= amount, "FundsModule: insufficient balance");
        payable(owner).transfer(amount);
    }
}
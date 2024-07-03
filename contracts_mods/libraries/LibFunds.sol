// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibModule, CachedModule} from '../core/LibModule.sol';
import {IModuleRegistry} from '../core/IModuleRegistry.sol';
import {IModuleRegistryProvider} from '../core/IModuleRegistryProvider.sol';
import {LibAccess} from './LibAccess.sol';

library LibFunds {
    
    function withdraw(uint256 amount) external {
        address owner = LibAccess.owner();
        require(owner == msg.sender, "FundsModule: caller is not the owner");
        require(address(this).balance >= amount, "FundsModule: insufficient balance");
        payable(owner).transfer(amount);
    }
}
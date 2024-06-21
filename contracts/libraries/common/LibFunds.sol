// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;


struct FundsStorage {
    address owner;
}


library LibFunds {

    bytes32 constant FUNDS_STORAGE_SLOT = keccak256("_FundsStorage");

    function load() internal pure returns (FundsStorage storage fs) {
        bytes32 slot = FUNDS_STORAGE_SLOT;
        assembly {
            fs.slot := slot
        }
    }

    function setOwner(address _owner) external {
        FundsStorage storage fs = load();
        fs.owner = _owner;
    }

    function owner() external view returns (address) {
        FundsStorage storage fs = load();
        return fs.owner;
    }

    function withdraw(uint256 amount) external {
        // Withdraw funds
        FundsStorage storage fs = load();
        require(fs.owner != address(0), "LibFunds: owner not set");
        require(address(this).balance >= amount, "LibFunds: insufficient balance");
        payable(fs.owner).transfer(amount);
    }
}
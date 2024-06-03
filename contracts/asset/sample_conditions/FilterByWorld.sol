// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "../IAssetCondition.sol";

contract FilterByWorld is IAssetCondition  {

    address owner;
    mapping(address => bool) public allowedWorlds;

    modifier onlyOwner {
        require(msg.sender == owner, "FilterByWorld: only owner allowed");
        _;
    }

    constructor(
        address _owner,
        address[] memory worlds
    ) {
        owner = _owner;
        for (uint256 i = 0; i < worlds.length; i++) {
            allowedWorlds[worlds[i]] = true;
        }
    }

    function canUse(address, address world, address, address) external view override returns (bool) {
        return allowedWorlds[world];
    }
 
    function canView(address, address world, address, address) external view override returns (bool) {
        return allowedWorlds[world];
    }

    function addWorld(address world) external onlyOwner {
        allowedWorlds[world] = true;
    }

    function removeWorld(address world) external onlyOwner {
        delete allowedWorlds[world];
    }

}
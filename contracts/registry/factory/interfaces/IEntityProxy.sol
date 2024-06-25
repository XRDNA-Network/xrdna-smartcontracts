// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

interface IEntityProxy {

    event EntityImplementationChanged(address indexed newImpl, uint256 version);
    function setImplementation(address _newImplementation, uint256 version) external;
    function implementationVersion() external view returns (uint256);
    function setAutomaticUpgrade(bool _alwaysUseLatest) external;
    function isAutomaticUpgrade() external view returns (bool);
}
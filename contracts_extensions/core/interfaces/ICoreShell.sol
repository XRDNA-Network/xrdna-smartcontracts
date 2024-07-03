// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import { ISupportsAccess } from "./ISupportsAccess.sol";
import {IExtension} from "../extensions/IExtension.sol";

interface ICoreShell is ISupportsAccess {

    /**
     * @dev Returns the primary owner of the contract
     */
    function owner() external view returns (address);

    /**
     * @dev Changes the owner of the contract. Only theh current owner can do this.
     */
    function changeOwner(address newOwner) external;

    /**
     * @dev Returns true if the extension is installed
     */
    function hasExtension(string memory name, uint256 version) external view returns (bool); 

    /**
     * @dev Returns the installed version of the extension
     */
    function getExtensionVersion(string memory name) external view returns (uint256);
}
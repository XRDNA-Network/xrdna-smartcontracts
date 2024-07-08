// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {ICoreApp} from '../interfaces/ICoreApp.sol';
import {LibExtensions} from '../libraries/LibExtensions.sol';
import {Version} from '../libraries/LibTypes.sol';
import {ICoreExtensionRegistry} from '../ext-registry/ICoreExtensionRegistry.sol';
import {IExtension, ExtensionInitArgs} from '../interfaces/IExtension.sol';
import {LibAccess} from '../libraries/LibAccess.sol';
import {IExtensionResolver} from '../interfaces/IExtensionResolver.sol';


abstract contract EntityShell is ICoreApp {

    IExtensionResolver public immutable extResolver;

    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "BasicShell: restricted to admins");
        _;
    }

    constructor(IExtensionResolver _extResolver) {
        require(address(_extResolver) != address(0), "EntityShell: extension resolver cannot be zero address");
        extResolver = _extResolver;
    }

    receive() external payable {}

     /**
     * @dev Returns true if the extension is installed
     */
    function hasExtension(string memory name, Version calldata version) external view returns (bool) {
        return extResolver.hasExtension(name, version);
    } 

    /**
     * @dev Returns the installed version of the extension
     */
    function getExtensionVersion(string memory name) external view returns (Version memory) {
        return extResolver.getExtensionVersion(name);
    }

    function withdraw(uint256 amount) external onlyAdmin {
        require(amount <= address(this).balance, "BasicShell: insufficient balance");
        payable(LibAccess.owner()).transfer(amount);
    }

    fallback() external payable {
        bytes4 selector = msg.sig;
        bytes memory result = _callFn(selector, msg.data);
        assembly {
            return(add(result, 0x20), mload(result))
        }
    }

    function _callFn(bytes4 _selector, bytes calldata data) private returns (bytes memory) {
        return LibExtensions.callExtensionWithResolver(_selector, data, extResolver);
    }
}
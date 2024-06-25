// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import { ICoreShell } from "./interfaces/ICoreShell.sol";
import {LibAccess, AccessStorage} from "./LibAccess.sol";
import {LibExtensions} from "./LibExtensions.sol";
import {IExtension} from "./extensions/IExtension.sol";
import {LibRoles} from "./LibRoles.sol";
import {IExtensionManager} from "./interfaces/IExtensionManager.sol";

struct CoreShellConstructorArgs {
    address owner; //can be zero
    address[] otherAdmins; //can be empty
    address extensionManager;
}

abstract contract CoreShell is ICoreShell  {
    IExtensionManager public immutable extManager;
    
    modifier onlyOwner {
        require(LibAccess.owner() == msg.sender, "CoreShell: not owner");
        _;
    }

    constructor(CoreShellConstructorArgs memory args) {

        LibAccess._setOwner(args.owner);
        for (uint256 i = 0; i < args.otherAdmins.length; i++) {
            LibAccess._grantRevokableRole(LibRoles.ROLE_ADMIN, args.otherAdmins[i]);
        }
        extManager = IExtensionManager(args.extensionManager);
    }


    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return LibAccess.hasRole(role, account);
    }

    function grantRole(bytes32 role, address account) public override onlyOwner {
        LibAccess.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override onlyOwner {
        LibAccess.revokeRole(role, account);
    }

    function hasExtension(string memory name, uint256 version) public view returns (bool) {
        return LibExtensions.hasExtension(name, version);
    }

    function getExtensionVersion(string memory name) public view returns (uint256) {
        return LibExtensions.getExtensionVersion(name);
    }

    function owner() public view override returns (address) {
        return LibAccess.owner();
    }

    function changeOwner(address newOwner) public override onlyOwner {
        LibAccess.setOwner(newOwner);
    }

    function supportsSelector(bytes4 selector) internal view returns (bool) {
        return extManager.hasSelector(selector);
    }


    function _setOwner(address account) internal {
        require(account != address(0), "Owner cannot be zero address");
        LibAccess._grantRevokableRole(LibRoles.ROLE_OWNER, account);
    }

    function _grantFixedRole(bytes32 role, address account) internal {
        LibAccess._grantFixedRole(role, account);
    }

    function _grantRevokableRole(bytes32 role, address account) internal {
        LibAccess._grantRevokableRole(role, account);
    }

    receive() external payable {}

    fallback() external payable {
        bytes4 selector = msg.sig;
        bytes memory result = _callFn(selector, msg.data);
        assembly {
            return(add(result, 0x20), mload(result))
        }
    }

    function _callFn(bytes4 _selector, bytes calldata data) private returns (bytes memory) {
        return LibExtensions.callExtensionWithResolver(_selector, data, extManager);
    }
}
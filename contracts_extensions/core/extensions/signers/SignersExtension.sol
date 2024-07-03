// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtension} from "../BaseExtension.sol";
import {ISignersExtension} from "./interfaces/ISignersExtension.sol";
import {ExtensionMetadata} from "../IExtension.sol";
import {AddSelectorArgs, SelectorArgs, LibExtensions} from "../../LibExtensions.sol";
import {LibAccess} from "../../LibAccess.sol";
import {LibRoles} from "../../LibRoles.sol";

contract SignersExtension is BaseExtension, ISignersExtension {


    function metadata() public override pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.core.SignersExt", 1);
    }

    function install(address myAddress) public virtual override {
        SelectorArgs[] memory sels = new SelectorArgs[](3);
        sels[0] = SelectorArgs({
            selector: this.isSigner.selector,
            isVirtual: false
        });
        sels[1] = SelectorArgs({
            selector: this.addSigners.selector,
            isVirtual: false
        });
        sels[2] = SelectorArgs({
            selector: this.removeSigners.selector,
            isVirtual: false
        });
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            selectors: sels,
            impl: myAddress
        }));
    }

    function initStorage(address owner, string calldata, uint256, bytes calldata) external override {
        LibAccess._grantRevokableRole(LibRoles.ROLE_SIGNER, owner);
    }

    function upgrade(address myAddress, uint256 currentVersion) public {
        //no-op
    }

    function isSigner(address _signer) public view returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_SIGNER, _signer);
    }

    function addSigners(address[] calldata _signers) public onlyOwner {
        for(uint256 i = 0; i < _signers.length; i++) {
            require(_signers[i] != address(0), "SignersExtension: zero address");
            LibAccess.grantRole(LibRoles.ROLE_SIGNER, _signers[i]);
        }
    }

    function removeSigners(address[] calldata _signers) public onlyOwner {
        for(uint256 i = 0; i < _signers.length; i++) {
            require(_signers[i] != address(0), "SignersExtension: zero address");
            LibAccess.revokeRole(LibRoles.ROLE_SIGNER, _signers[i]);
        }
    }
}
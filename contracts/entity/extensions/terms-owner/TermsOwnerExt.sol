// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtension} from '../../../core/extensions/BaseExtension.sol';
import {ExtensionMetadata} from '../../../core/extensions/IExtension.sol';
import {SelectorArgs, AddSelectorArgs, LibExtensions} from '../../../core/LibExtensions.sol';
import {LibTermsOwner} from '../../libraries/LibTermsOwner.sol';
import {RegistrationTerms} from '../../../registry/extensions/registration/interfaces/IRegistration.sol';
import {LibAccess} from '../../../core/LibAccess.sol';
import {LibRoles} from '../../../core/LibRoles.sol';
import {ITermsOwnerExtension} from './interfaces/ITermsOwnerExtension.sol';
import {ITermsOwner} from './interfaces/ITermsOwner.sol';
import {LibEntity} from '../../libraries/LibEntity.sol';

contract TermsOwnerExt is BaseExtension, ITermsOwnerExtension {


    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() public pure override returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.entity.TermsOwnerExt", 1);
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) public override virtual {
        SelectorArgs[] memory sels = new SelectorArgs[](4);
        sels[0] = SelectorArgs({
            selector: this.setTerms.selector,
            isVirtual: false
        });
        sels[1] = SelectorArgs({
            selector: this.getTerms.selector,
            isVirtual: false
        });
        sels[2] = SelectorArgs({
            selector: this.isStillActive.selector,
            isVirtual: false
        });
        sels[3] = SelectorArgs({
            selector: this.isSigner.selector,
            isVirtual: false
        });
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            selectors: sels,
            impl: myAddress
        }));

    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress, uint256 currentVersion) public override {
        //no-op
    }

    function setTerms(RegistrationTerms calldata terms) public onlyAdmin {
        require(terms.gracePeriodDays > 0, "TermsOwnerExt: grace period must be greater than 0");
        LibTermsOwner.load().terms = terms;
    }

    function getTerms() public view returns (RegistrationTerms memory) {
        return LibTermsOwner.load().terms;
    }

    //marked as virtual so removable extension can override
    function isStillActive() public view returns (bool) {
        return LibEntity.load().active;
    }

    function isSigner(address a) public view returns (bool) {
        return LibAccess.hasRole(LibRoles.ROLE_SIGNER, a);
    }
}
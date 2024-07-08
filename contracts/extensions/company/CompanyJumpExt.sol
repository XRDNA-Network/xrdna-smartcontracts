// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata, ExtensionInitArgs} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {ICompany, DelegatedAvatarJumpRequest} from '../../company/instance/ICompany.sol';
import {LibCompany, CompanyStorage} from '../../company/instance/LibCompany.sol';
import {IAvatar, DelegatedJumpRequest} from '../../avatar/instance/IAvatar.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';

contract CompanyJumpExt is IExtension {


    modifier onlyAdmin {
        require(LibAccess.isAdmin(msg.sender), "CompanyAddExperienceExt: restricted to admins");
        _;
    }

    modifier onlySigner {
        require(LibAccess.isSigner(msg.sender), "FactoCompanyAddExperienceExtryExt: restricted to signers");
        _;
    }

    modifier onlyIfActive {
        require(LibRemovableEntity.load().active, "Company: company is not active");
        _;
    }

     /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.COMPANY_JUMP,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](1);
        sigs[0] = SelectorInfo({
            selector: this.delegateJumpForAvatar.selector,
            name: "delegateJumpForAvatar(DelegatedAvatarJumpRequest)"
        });
        
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    /**
     * @dev Upgrades the extension. See note above about upgrades
     */
    function upgrade(address myAddress) external {
        //no-op
    }


    function delegateJumpForAvatar(DelegatedAvatarJumpRequest calldata request) public onlySigner onlyIfActive {
        
        IAvatar avatar = IAvatar(request.avatar);
        //go through avatar contract to make the jump so that it pays the fee
        avatar.delegateJump(DelegatedJumpRequest({
            portalId: request.portalId,
            agreedFee: request.agreedFee,
            avatarOwnerSignature: request.avatarOwnerSignature
        }));
        emit ICompany.CompanyJumpedForAvatar(request.avatar, request.portalId, request.agreedFee);
    }

}
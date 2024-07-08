// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {IExperience, JumpEntryRequest} from '../../experience/instance/IExperience.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {LibExperience, ExperienceStorage} from '../../libraries/LibExperience.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';

contract ExperienceJumpExt is IExtension {


    modifier onlyPortalRegistry {
        address pr = IExperience(address(this)).portalRegistry();
        require(pr != address(0), "Experience: portal registry not set");
        require(pr == msg.sender, "Experience: caller is not the portal registry");
        _;
    }

    modifier onlyIfActive {
        require(LibRemovableEntity.load().active, "Experience: not currently active");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.EXPERIENCE_JUMP,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](1);
        sigs[0] = SelectorInfo({
            selector: this.entering.selector,
            name: "entering(JumpEntryRequest)"
        });
        
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    function upgrade(address myAddress) external {
        //no-op
    }

    function entering(JumpEntryRequest memory) external payable onlyPortalRegistry onlyIfActive returns (bytes memory)  {
        ExperienceStorage storage s = LibExperience.load();
        
        if(s.entryFee > 0) {
            require(msg.value == s.entryFee, "Experience: incorrect entry fee");
            payable(address(LibRemovableEntity.load().termsOwner)).transfer(msg.value);
        }
        return s.connectionDetails;
    }

}
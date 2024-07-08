// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IExtension, ExtensionMetadata} from '../../interfaces/IExtension.sol';
import {Version} from '../../libraries/LibTypes.sol';
import {LibExtensionNames} from '../../libraries/LibExtensionNames.sol';
import {LibAccess} from '../../libraries/LibAccess.sol';
import {IExperience} from '../../experience/instance/IExperience.sol';
import {LibExtensions, AddSelectorArgs, SelectorInfo} from '../../libraries/LibExtensions.sol';
import {LibRemovableEntity} from '../../libraries/LibRemovableEntity.sol';
import {VectorAddress} from '../../libraries/LibVectorAddress.sol';
import {ICompany} from '../../company/instance/ICompany.sol';
import {LibExperience} from '../../libraries/LibExperience.sol';
import {ICompanyRegistry} from '../../company/registry/ICompanyRegistry.sol';

contract ExperienceInfoExt is IExtension {


    modifier onlyActiveOwningCompany {
        address cr = IExperience(address(this)).companyRegistry();
        require(cr != address(0), "Company: company registry not set");
        require(ICompanyRegistry(cr).isRegistered(msg.sender), "Company: caller is not a registered company");
        require(company() == msg.sender, "Company: caller is not the owning company");
        require(ICompany(msg.sender).isEntityActive(), "Company: company is not active");
        _;
    }

    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata({
            name: LibExtensionNames.EXPERIENCE_INFO,
            version: Version(1,0)
        });
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) external {
        SelectorInfo[] memory sigs = new SelectorInfo[](6);
        
        sigs[0] = SelectorInfo({
            selector: this.company.selector,
            name: "company()"
        });
        sigs[1] = SelectorInfo({
            selector: this.world.selector,
            name: "world()"
        });
        sigs[2] = SelectorInfo({
            selector: this.vectorAddress.selector,
            name: "vectorAddress()"
        });
        sigs[3] = SelectorInfo({
            selector: this.entryFee.selector,
            name: "entryFee()"
        });
        sigs[4] = SelectorInfo({
            selector: this.setConnectionDetails.selector,
            name: "setConnectionDetails(bytes)"
        });
        sigs[5] = SelectorInfo({
            selector: this.connectionDetails.selector,
            name: "connectionDetails()"
        });
        
        LibExtensions.addExtensionSelectors(AddSelectorArgs({
            impl: myAddress,
            selectors: sigs        
        }));
    }

    function upgrade(address myAddress) external {
        //no-op
    }

    /**
     * @dev Returns the company that controls this experience
     */
    function company() public view returns (address) {
        return LibRemovableEntity.load().termsOwner;
    }

    /**
     * @dev Returns the world that this experience is in
     */
    function world() public view returns (address) {
        return ICompany(LibRemovableEntity.load().termsOwner).world();
    }

    /**
     * @dev Returns the spatial vector address for this experience, which is derived
     * from its parent company and world.
     */
    function vectorAddress() public view returns (VectorAddress memory) {
        return LibRemovableEntity.load().vector;
    }

    /**
     * @dev Returns the entry fee for this experience
     */
    function entryFee() public view returns (uint256) {
        return LibExperience.load().entryFee;
    }

    function connectionDetails() public view returns (bytes memory) {
        return LibExperience.load().connectionDetails;
    }

    /**
     * @dev Sets the connection details for the experience. This can only be called by the parent company contract
     */
    function setConnectionDetails(bytes memory details) external onlyActiveOwningCompany {
        LibExperience.load().connectionDetails = details;
        emit IExperience.ConnectionDetailsChanged(details);
    }
}
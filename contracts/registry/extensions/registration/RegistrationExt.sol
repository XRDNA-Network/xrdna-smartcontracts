// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {BaseExtension} from "../../../core/extensions/BaseExtension.sol";
import {IRegistration, 
        RegistrationTerms,    
        RegisterEntityArgsNoTermsNoRemoval, 
        RegisterEntityArgsNoTermsWithRemoval,
        RegisterEntityArgsWithTerms
} from "./interfaces/IRegistration.sol";
import {IRegistry} from '../../interfaces/IRegistry.sol';
import {ExtensionMetadata} from '../../../core/extensions/IExtension.sol';
import {SelectorArgs, AddSelectorArgs, LibExtensions} from '../../../core/LibExtensions.sol';
import {RegistrationStorage, TermedRegistration, LibRegistration} from '../../libraries/LibRegistration.sol';
import {IRegisteredEntity} from '../../../entity/interfaces/IRegisteredEntity.sol';
import {LibStringCase} from '../../../libraries/common/LibStringCase.sol';

contract RegistrationExt is BaseExtension, IRegistration {

    using LibStringCase for string;


    modifier onlyRegistrationAuthority() {
        require(IRegistry(address(this)).isActiveTermsOwner(msg.sender), "RegistrationExt: caller is not an active registration terms owner");
        _;
    }

    
    /**
     * @dev Returns metadata about the extension.
     */
    function metadata() external pure returns (ExtensionMetadata memory) {
        return ExtensionMetadata("xr.registration.RegistrationExt", 1);
    }

    /**
     * @dev Installs the extension.
     */
    function install(address myAddress) public virtual {
        SelectorArgs[] memory sels = new SelectorArgs[](5);
        sels[0] = SelectorArgs({
            selector: this.isRegistered.selector,
            isVirtual: false
        });
        sels[1] = SelectorArgs({
            selector: this.getEntityByName.selector,
            isVirtual: false
        });
        sels[2] = SelectorArgs({
            selector: this.registerEntityNoTermsNoRemoval.selector,
            isVirtual: false
        });
        sels[3] = SelectorArgs({
            selector: this.registerEntityNoTermsWithRemoval.selector,
            isVirtual: false
        });
        sels[4] = SelectorArgs({
            selector: this.registerEntityWithTerms.selector,
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
    function upgrade(address myAddress, uint256 currentVersion) public {
        //no-op
    }


    function isRegistered(address addr) public view returns (bool) {
        RegistrationStorage storage rs = LibRegistration.load();
        bool isStatic = rs.staticRegistrations[addr];
        if(isStatic) {
            return true;
        }
        return address(rs.removableRegistrations[addr].owner) != address(0);
    }

    function getEntityByName(string calldata name) public view returns (address) {
        RegistrationStorage storage rs = LibRegistration.load();
        return rs.registrationsByName[name.lower()];
    }

    function createEntityInstance(address, string calldata, bytes calldata) public pure returns (address) {
        revert("RegistrationExt: createEntityInstance not implemented");
    }

    function registerEntityNoTermsNoRemoval(RegisterEntityArgsNoTermsNoRemoval calldata args) public payable onlyRegistrationAuthority {
    
        address a = IRegistry(address(this)).createEntityInstance(args.owner, args.name, args.initData);
        require(a != address(0), "RegistrationExt: entity creation failed");
    
        IRegisteredEntity entity = IRegisteredEntity(a);
        RegistrationStorage storage rs = LibRegistration.load();
        require(rs.staticRegistrations[a] == false, "RegistrationExt: entity already registered");
        string memory name = entity.name().lower();
        require(rs.registrationsByName[name] == address(0), "RegistrationExt: entity name already registered");
        rs.registrationsByName[name] = a;
        rs.staticRegistrations[a] = true;
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(a).transfer(msg.value);
            }
        }

        emit EntityRegistered(a, msg.sender);
    }

    function registerEntityNoTermsWithRemoval(RegisterEntityArgsNoTermsWithRemoval calldata args) public payable onlyRegistrationAuthority {
        address a = IRegistry(address(this)).createEntityInstance(args.owner, args.name, args.initData);
        require(a != address(0), "RegistrationExt: entity creation failed");
        IRegisteredEntity entity = IRegisteredEntity(a);
        _basicTermedRegistration(entity, RegistrationTerms(0, 0, args.gracePeriodDays));
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(address(entity)).transfer(msg.value);
            }
        }
    }

    function registerEntityWithTerms(RegisterEntityArgsWithTerms calldata args) public payable onlyRegistrationAuthority {
        address a = IRegistry(address(this)).createEntityInstance(args.owner, args.name, args.initData);
        require(a != address(0), "RegistrationExt: entity creation failed");
        IRegisteredEntity entity = IRegisteredEntity(a);
        _basicTermedRegistration(entity, args.terms);
        if(msg.value > 0) {
            if(args.sendTokensToOwner) {
                payable(args.owner).transfer(msg.value);
            } else {
                payable(address(entity)).transfer(msg.value);
            }
        }
    }

    function _basicTermedRegistration(IRegisteredEntity entity, RegistrationTerms memory terms) internal {
        RegistrationStorage storage rs = LibRegistration.load();
        TermedRegistration storage reg = rs.removableRegistrations[address(entity)];
        string memory name = entity.name().lower();
        require(rs.registrationsByName[name] == address(0), "RegistrationExt: entity name already registered");
        require(address(reg.owner) == address(0), "RegistrationExt: entity already registered with different name??");
        //FIXME with terms owner provider interface
        reg.owner = msg.sender;
        reg.terms = terms;
        reg.lastRenewed = block.timestamp;
        rs.registrationsByName[name] = address(entity);
        
        emit EntityRegistered(address(entity), msg.sender);
    }
}
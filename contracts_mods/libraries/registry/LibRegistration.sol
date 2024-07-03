// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {LibDelegation} from '../../core/LibDelegation.sol';
import {
    IRegistration, 
    RegistrationTerms,
    ChangeEntityTermsArgs
} from '../../modules/registration/IRegistration.sol';

interface IRegProvider {
    function registrationLogic() external view returns (IRegistration);
}
library LibRegistration {

    using LibDelegation for address;

    function _getRegistration() internal view returns (IRegistration) {
        return IRegProvider(address(this)).registrationLogic();
    }

    function isRegistered(address addr) external view returns (bool) {
        IRegistration entry = _getRegistration();
        bytes memory data = abi.encodeWithSelector(IRegistration.isRegistered.selector, addr);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (bool));
    }

    function getEntityByName(string calldata name) external view returns (address) {
        IRegistration entry = _getRegistration();
        bytes memory data = abi.encodeWithSelector(IRegistration.getEntityByName.selector, name);
        bytes memory r = address(entry).sCall(data);
        return abi.decode(r, (address));
    }

    function registerEntityNoTermsNoRemoval(address entity) external {
        IRegistration entry = _getRegistration();
        bytes memory data = abi.encodeWithSelector(IRegistration.registerEntityNoTermsNoRemoval.selector, entity);
        address(entry).dCall(data);
    }

    function registerEntityNoTermsWithRemoval(address a, uint16 gracePeriodDays) external {
        IRegistration entry = _getRegistration();
        bytes memory data = abi.encodeWithSelector(IRegistration.registerEntityNoTermsWithRemoval.selector, a, gracePeriodDays);
        address(entry).dCall(data);
    }

    function registerEntityWithTerms(address a, RegistrationTerms calldata terms) external  {
        IRegistration entry = _getRegistration();
        bytes memory data = abi.encodeWithSelector(IRegistration.registerEntityWithTerms.selector, a, terms);
        address(entry).dCall(data);
    }

    function changeEntityTerms(ChangeEntityTermsArgs calldata args) external {
        IRegistration entry = _getRegistration();
        bytes memory data = abi.encodeWithSelector(IRegistration.changeEntityTerms.selector, args);
        address(entry).dCall(data);
    }
}
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IRemovableEntity} from '../../modules/registration/IRemovableEntity.sol';
import {IControlChange, ChangeControllerArgsNoTerms, ChangeControllerArgsWithTerms} from '../../modules/control-change/IControlChange.sol';
import {LibDelegation} from '../../core/LibDelegation.sol';

interface CCProvider {
    function controlChangeLogic() external view returns (IControlChange);
}
library LibControlChange {

     using LibDelegation for address;

     function _getControlChange() internal view returns (IControlChange) {
         return CCProvider(address(this)).controlChangeLogic();
     }

    function changeControllerNoTerms(ChangeControllerArgsNoTerms calldata args) external {
        IControlChange entry = _getControlChange();
        bytes memory data = abi.encodeWithSelector(IControlChange.changeControllerNoTerms.selector, args);
        address(entry).dCall(data);
    }

    function changeControllerWithTerms(ChangeControllerArgsWithTerms calldata args) external {
        IControlChange entry = _getControlChange();
        bytes memory data = abi.encodeWithSelector(IControlChange.changeControllerWithTerms.selector, args);
        address(entry).dCall(data);
    }
}
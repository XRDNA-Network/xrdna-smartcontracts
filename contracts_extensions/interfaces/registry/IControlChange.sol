// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {RegistrationTerms} from '../../libraries/LibTypes.sol';

struct ChangeControllerArgs {
    address entity;
    
    bytes oldControllerSignature;

    bytes entitySignature;

    uint256 expiration;

    RegistrationTerms newTerms;
}

interface IControlChange {

    event ControllerChanged(address indexed entity, address indexed newController);

   /**
     * @dev Change the controller that can activate/deactivate/remove the entity. The new controller can set terms 
     * for the entity (i.e. any terms with fee and coveragePeriodDays > 0). If provided, the initial terms are signed by the entity, 
     * but not the previous controller. The previous controller only signs the entity address, new controller 
     * address, expiration time. The entity must sign the new controller address, terms, and expiration time, 
     * or the same values as old controller if no terms are provided. No nonce is required since the expiration 
     * time is used to prevent replay attacks. 
     * This must be called by the new controller contract.
     */
    function changeController(ChangeControllerArgs calldata args) external;

}